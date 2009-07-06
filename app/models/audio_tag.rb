class AudioTag < ActiveRecord::Base
  belongs_to :audio_file
  validates_presence_of :audio_file, :format, :offset, :data
  validates_numericality_of :offset, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true

  def useable?
    artist && album && track
  end

  def format
    self[:format]
  end

  def tag_attributes
    unless @ta and @data == @ta_data
      # Read tag attributes
      @ta_data= @data
      @ta= case format
      when 'id3'
        id3= Mp3Info.open(File.filename_for_stringio(data+"\xff\xfb\xa0\x40\x00"))
        id3.tag2.merge(id3.tag)
      when 'ape'
        h= ApeTag.new(StringIO.new(data)).fields
        h.each{|k,v| h[k]= v.first if v.is_a?(Array)}
        h
      else
        raise "Unsupported tag format: #{format}"
      end
      @ta= CICPHash.new.merge @ta unless @ta.is_a?(CICPHash)

      # Post-process
      case format
      when 'id3'
        @ta[:tn]= @ta[:tracknum]
        @ta[:year]||= @ta[:TDRC]
      when 'ape'
        @ta[:tn]= @ta[:track]
      end
    end
    @ta
  end
  alias_method :ta, :tag_attributes

  def artist
    ta[:artist]
  end
  def album
    ta[:album]
  end
  def year
    ta[:year].safe_to_i
  end
  def track
    ta[:title]
  end
  def tn
    v= ta[:tn]
    v.sub! /\/\d+$/, '' if v.is_a?(String)
    v.safe_to_i
  end
end
