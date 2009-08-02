class SearchQuery < ActiveRecord::Base
  serialize :params #, Hash
  validates_presence_of :name, :params
  validates_uniqueness_of :name, :allow_blank => false, :allow_nil => true

  def to_find_options
    @options= {}
    params.each{|key,value|
      send PARAM_PROCESSOR_MAP[key], value if value
    }
    @options
  end

  def params=(params)
    if params
      raise "Invalid type of params object. Hash expected but was #{params.class}." unless params.is_a?(Hash)
      params= params.symbolize_keys.reject{|k,v| !VALID_PARAMS.include?(k) or v.blank?}
    end
    write_attribute :params, params
  end

  # ============================= Conditions =============================

  def process_param_artist(v)
    add_associations :joins, :artist
    add_text_condition 'artists.name', v
  end

  def process_param_album(v)
    add_text_condition 'albums.name', v
  end

  def process_param_track(v)
    add_associations :joins, {:discs => :tracks}
    add_text_condition 'tracks.name', v
  end

  private
    def add_text_condition(field, v)
      add_conditions "upper(#{field}) LIKE upper(?)", "%#{v}%"
    end

  # ============================== Constants ==============================

  public
  unless const_defined?(:PARAM_PROCESSOR_MAP)
    PARAM_PROCESSOR_MAP= SearchQuery.instance_methods.select{|m| m.starts_with?('process_param_')} \
      .inject({}){|h,m| m =~ /^process_param_(.+)$/; h[$1.to_sym]= m; h}.freeze
    VALID_PARAMS= PARAM_PROCESSOR_MAP.keys.freeze
  end

  # =========================== Utility methods ===========================

  class << self
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

    def prepare_array_based_option!(hash, key)
      case hash[key]
      when nil then hash[key]= []
      when Array then ; # do nothing
      else hash[key]= [hash[key]]
      end
    end

    def add_query_conditions!(hash, sql, *params)
      if hash[:conditions]
        hash[:conditions][0]+= " AND #{sql}"
        hash[:conditions].concat params
      else
        hash[:conditions]= [sql, *params]
      end
      hash
    end
  end

  def add_associations(key, value)
    self.class.add_associations!(@options, key, value)
  end

  def add_conditions(sql, *params)
    self.class.add_query_conditions!(@options, sql, *params)
  end
end
