class SearchQuery < ActiveRecord::Base
  serialize :params #, Hash
  validates_presence_of :name, :params
  validates_uniqueness_of :name, :allow_blank => false, :allow_nil => true

  def to_find_options
    options= {}

    if params[:artist]
      add_associations! options, :joins, :artist
      add_conditions! options, 'upper(artists.name) LIKE upper(?)', "%#{params[:artist]}%"
    end

    if params[:album]
      add_conditions! options, 'upper(albums.name) LIKE upper(?)', "%#{params[:album]}%"
    end

    if params[:track]
      add_associations! options, :joins, {:discs => :tracks}
      add_conditions! options, 'upper(tracks.name) LIKE upper(?)', "%#{params[:track]}%"
    end

    options
  end

  # Adds tables for either :join or :include
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

  def add_conditions!(hash, sql, *params)
    if hash[:conditions]
      hash[:conditions][0]+= " AND #{sql}"
      hash[:conditions].concat params
    else
      hash[:conditions]= [sql, *params]
    end
    hash
  end
end
