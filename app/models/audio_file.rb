class AudioFile < ActiveRecord::Base
  belongs_to :audio_content
  has_many :audio_tags
  validates_presence_of :audio_content, :dirname, :basename, :size

  def filename
    File.expand_path File.join(dirname,basename)
  end

  def exists?
    File.exists? filename
  end
end
