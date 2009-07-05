class AudioTag < ActiveRecord::Base
  belongs_to :audio_file
  validates_presence_of :audio_file, :format, :offset, :data
  validates_numericality_of :offset, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true

  def useable?
    artist && album && track
  end

  def tag_attributes
    return @ta if @ta and @data == @ta_data
    @ta_data= @data
    @ta= case format
    when 'ape'
      h= ApeTag.new(StringIO.new(data)).fields
      h.each{|k,v| h[k]= v.first if v.is_a?(Array)}
      h
    else
      raise "Unsupported tag format: #{format}"
    end
  end
  alias_method :ta, :tag_attributes

  def artist
    ta['Artist']
  end
  def album
    ta['Album']
  end
  def year
    ta['Year'].safe_to_i
  end
  def track
    ta['Title']
  end
  def tn
    v= ta['Track']
    v.sub! /\/\d+$/, '' if v.is_a?(String)
    v.safe_to_i
  end
end
