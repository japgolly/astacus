# To add a new param type:
# Either a)
#   * Add a process_param_xxxx() method.
#   * Optionally add a validate_param_xxxx() method.
#   * Optionally add a preprocess_param_xxxx() method.
#   * Add tests to search_query_filter_results.rb
# or b)
#   * Declare the param using one of the generic add_xxx_param methods.
#   * Add tests to search_query_filter_results.rb
class SearchQuery < ActiveRecord::Base
  serialize :params #, Hash
  validates :params, :presence => true
  validates :name, :presence => true, :uniqueness => { :allow_blank => false, :allow_nil => true }

  # Returns a new instance that is meant to be used temporarily and not saved.
  def self.tmp(params)
    SearchQuery.new(:params => params, :name => :tmp)
  end

  def params=(params)
    if params
      raise "Invalid type of params object. Hash expected but was #{params.class}." unless params.is_a?(Hash)
      params= params.symbolize_keys.reject{|k,v| !VALID_PARAMS.include?(k) or v.blank?}

      # Preprocess params
      params.keys.each{|key|
        m= PARAM_PREPROCESSOR_MAP[key]
        params[key]= send(m,params[key]) if m
      }
    end

    write_attribute :params, params
  end

  def to_find_options
    @options= {}
    params.each{|key,value|
      send PARAM_PROCESSOR_MAP[key], value
    }
    @options
  end

  protected
  def validate
    if params
      if !params.is_a?(Hash)
        errors.add :params, "is not a Hash object. (actual class = #{params.class})"
      else
        # Validate each param
        params.each{|key,value|
          if m= PARAM_VALIDATOR_MAP[key]
            errstr= send m, value
            errors.add key, errstr if errstr
          end
        }
      end
    end
  end

  # ========================= Generic Conditions =========================
  protected

  class << self
    def apply_param_def_options(body, options={})
      options.assert_valid_keys(:joins)
      if v= options[:joins]
        body= "add_associations :joins, #{v.inspect}; #{body}"
      end
      body
    end

    def add_param(name, type, sql_column, options={})
      process_body= apply_param_def_options("add_#{type}_condition '#{sql_column}',v", options)
      class_eval <<-EOB
        def preprocess_param_#{name}(v) preprocess_#{type}_param(v) end
        def validate_param_#{name}(v) validate_#{type}_param(v) end
        def process_param_#{name}(v) #{process_body} end
      EOB
    end
  end

  def preprocess_boolean_isnull_param(v) v end
  def validate_boolean_isnull_param(v)
    return nil if %w[0 1].include?(v)
    return "is invalid. Must be either 0 or 1."
  end
  def add_boolean_isnull_condition(field, v)
    add_conditions "#{field} IS #{'NOT ' if v == '1'}NULL"
  end

  def preprocess_boolean_01_param(v) v end
  def validate_boolean_01_param(v)
    return nil if %w[0 1].include?(v)
    return "is invalid. Must be either 0 or 1."
  end
  def add_boolean_01_condition(field, v)
    add_conditions "#{field} = #{v}"
  end

  # Removes whitespace.
  # Adds a single space after commas
  # Changes bbb-aaa to aaa-bbb
  # Changes aaa-aaa to aaa
  def preprocess_int_param(v)
    v.gsub(/\s+/,'').gsub(',',', ').gsub(/(\d+)\-(\d+)/){|f|
      a,b=$1.to_i,$2.to_i
      if a == b
        a.to_s
      elsif b < a
        "#{b}-#{a}"
      else
        f
      end
    }
  end
  VALID_INT_EXPRESSIONS= [
    /^\d+$/,
    /^(\d+)\-(\d+)$/,
    /^\-(\d+)$/, /^\<\=(\d+)$/, /^\=\<(\d+)$/,
    /^(\d+)\+$/, /^(\d+)\>\=$/, /^(\d+)\=\>$/,
    /^\<(\d+)$/,
    /^(\d+)\>$/,
  ].freeze
  def validate_int_param(value_str)
    value_str.split(', ').each{|v|
      if VALID_INT_EXPRESSIONS.map{|regex| v =~ regex}.uniq == [nil]
        return "is invalid. Cannot process: #{v.inspect}"
      end
    }
    nil
  end
  # Accepts a list of clauses, each of which must be one of the following
  # where xxxx is an integer:
  # * xxxx
  # * xxxx-yyyy
  # * xxxx+
  # * -xxxx
  # * <xxxx
  # * <=xxxx
  # * xxxx>
  # * xxxx>=
  # * xxxx=>
  def add_int_condition(field, value_str)
    sql= []
    params= []
    value_str.split(', ').each{|v|
      case v
      when /^\d+$/
        sql<< "#{field} = ?"
        params<< v
      when /^(\d+)\-(\d+)$/
        sql<< "#{field} between ? and ?"
        params<< $1
        params<< $2
      when /^\-(\d+)$/, /^\<\=(\d+)$/, /^\=\<(\d+)$/
        sql<< "#{field} <= ?"
        params<< $1
      when /^(\d+)\+$/, /^(\d+)\>\=$/, /^(\d+)\=\>$/
        sql<< "#{field} >= ?"
        params<< $1
      when /^\<(\d+)$/
        sql<< "#{field} < ?"
        params<< $1
      when /^(\d+)\>$/
        sql<< "#{field} > ?"
        params<< $1
      else
        raise "Cannot process integer field: #{v.inspect}"
      end
    }
    add_conditions "(#{sql.join ' OR '})", *params
  end

  def preprocess_text_param(v) v end
  def validate_text_param(v) nil end
  def add_text_condition(field, v)
    add_conditions "upper(#{field}) LIKE upper(?)", "%#{v}%"
  end

  def preprocess_taglist_param(v)
    found= {}
    v= v.gsub(/[ ,]+/,' ').gsub(/^ +| +$/,'').sub(/^! */,'! ') \
      .split(' ').reject{|el| r= found[el]; found[el]= true; r}.join(' ')
  end
  def validate_taglist_param(v) nil end
  def add_taglist_condition(field, v)
    tags= v.split(' ')
    unless tags[0] == '!'
      # POSITIVE
      if tags.size == 1
        add_conditions "#{field} = ?", tags[0]
      else
        add_conditions "#{field} in (?#{',?' * (tags.size-1)})", *tags
      end
    else
      # NEGATIVE
      tags.shift
      if tags.size == 1
        add_conditions "#{field} != ?", tags[0]
      else
        add_conditions "#{field} not in (?#{',?' * (tags.size-1)})", *tags
      end
    end
  end

  # ============================= Conditions =============================
  protected

  add_param :album, :text, 'albums.name'
  add_param :albumart, :boolean_isnull, 'albums.albumart_id'
  add_param :artist, :text, 'artists.name', :joins => Album::JOIN_TO_AR
  add_param :bitrate, :int, 'audio_content.bitrate', :joins => Album::JOIN_TO_AC
  add_param :disc, :text, 'discs.name', :joins => Album::JOIN_TO_DISCS
  add_param :discs, :int, 'albums.discs_count'
  add_param :track, :text, 'tracks.name', :joins => Album::JOIN_TO_TRACKS
  add_param :va, :boolean_01, 'discs.va', :joins => Album::JOIN_TO_DISCS
  add_param :year, :int, 'albums.year'

  add_param :location, :taglist, 'locations.label', :joins => Album::JOIN_TO_LOC
  def validate_param_location(v)
    tags= v.split(' ')
    tags.shift if tags[0] == '!'
    missing= tags.reject{|tag| Location.find_by_label(tag)}
    "specifies tags that dont exist: #{missing.join ', '}" unless missing.empty?
  end

  # ============================== Constants ==============================

  private
  def self.create_method_map(prefix)
    SearchQuery.instance_methods.select{|m| m.starts_with?(prefix)} \
      .inject({}){|h,m| h[m[prefix.length..-1].to_sym]= m; h}
  end

  public
  unless const_defined?(:PARAM_PROCESSOR_MAP)
    PARAM_PROCESSOR_MAP= create_method_map('process_param_').freeze
    PARAM_PREPROCESSOR_MAP= create_method_map('preprocess_param_').freeze
    PARAM_VALIDATOR_MAP= create_method_map('validate_param_').freeze
    VALID_PARAMS= PARAM_PROCESSOR_MAP.keys.freeze
  end

  # =========================== Utility methods ===========================

  class << self
    public

    # Adds to a list of associations formatted for :join / :include options to find().
    def add_associations!(hash, key, value)
      case value
      when Array
        value.each{|v| add_associations! hash, key, v}
      when Hash
        prepare_array_based_option! hash, key
        value.each{|k,v|
          hash[key].delete k
          unless ch= hash[key].select{|el| el.is_a?(Hash) && el.has_key?(k)}.first
            ch= {k => []}
            hash[key]<< ch
          end
          add_associations! ch, k, v
        }
      else
        prepare_array_based_option! hash, key
        hash[key]<< value unless hash[key].include?(value)
      end
      hash
    end

    # Adds to a find :conditions array.
    def add_query_conditions!(hash, sql, *params)
      if hash[:conditions]
        hash[:conditions][0]+= " AND #{sql}"
        hash[:conditions].concat params
      else
        hash[:conditions]= [sql, *params]
      end
      hash
    end

    protected
    def prepare_array_based_option!(hash, key)
      case hash[key]
      when nil then hash[key]= []
      when Array then ; # do nothing
      else hash[key]= [hash[key]]
      end
    end
  end # class << self

  protected
  def add_associations(key, value)
    self.class.add_associations!(@options, key, value)
  end

  def add_conditions(sql, *params)
    self.class.add_query_conditions!(@options, sql, *params)
  end
end
