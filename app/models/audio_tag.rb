class AudioTag < ActiveRecord::Base
  belongs_to :audio_file
  belongs_to :albumart, :class_name => "Image"
  has_and_belongs_to_many :tracks, :uniq => true
  validates_presence_of :audio_file, :format, :offset, :data
  validates_numericality_of :offset, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true

  before_destroy do |r|
    r.tracks.each {|t| t.destroy if t.audio_tags.size == 1 }
  end

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
        id3= Mp3Info.open(File.filename_for_stringio(data+"\xff\xfb\xa0\x40\x00"), :encoding => 'utf-8')
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
        @ta[:cd]= @ta[:TPOS] # TODO Test this with id3 tag < 2.3
        @ta[:year]||= @ta[:TDRC]
        if @ta['APIC']
          if @ta['APIC'] =~ /^([\000\003](.*?)\000[\x00-\x14](.*?)\000)/m or @ta['APIC'] =~ /^([\001\002](.*?)\000[\x00-\x14](.*?)\000\000)/m
            @ta[:albumart_mimetype]= $2
            @ta[:albumart_raw]= @ta['APIC'][$1.size..-1]
          else
            #raise
          end
        end
      when 'ape'
        @ta[:tn]= @ta[:track]
        @ta[:cd]= @ta[:disc]
      end
    end
    @ta
  end
  alias_method :ta, :tag_attributes

  # Raw string fields
  %w[artist album albumart_mimetype albumart_raw].each{|m|
    class_eval "def #{m}; ta[:#{m}] end"
  }
  # Integer fields
  %w[year].each{|m|
    class_eval "def #{m}; ta[:#{m}].safe_to_i end"
  }
  # Compound integer fields
  %w[tn cd].each{|m|
    class_eval "def #{m}; v= ta[:#{m}]; v.sub! /\\/\\d+$/, '' if v.is_a?(String); v.safe_to_i end"
  }
  # Other
  def track
    ta[:title]
  end
end
