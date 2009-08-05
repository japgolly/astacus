class AudioFile < ActiveRecord::Base
  belongs_to :audio_content
  belongs_to :location
  has_many :audio_tags, :dependent => :destroy
  has_many :tracks
  acts_as_unique
  validates_presence_of :audio_content, :dirname, :basename, :size
  validates_numericality_of :size, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_format_of :basename, :with => %r!\A[^/]+\Z!, :allow_nil => true

  def filename
    File.expand_path File.join(dirname,basename)
  end

  def file_ext
    basename =~ /^.+\.([^\.\\\/]*)$/ ? $1 : nil
  end

  def mimetype
    ext= file_ext
    return 'audio/mpeg' if ext =~ /^mp(?:[23]|ga)$/
    "audio/#{ext}"
  end

  def exists?
    File.exists? filename
  end
end
