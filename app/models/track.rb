class Track < ActiveRecord::Base
  belongs_to :disc
  belongs_to :audio_file
  has_and_belongs_to_many :audio_tags, :uniq => true

  validates_presence_of :disc, :audio_file, :name
  validates_numericality_of :tn, :only_integer => true, :allow_nil => true

  acts_as_unique

  after_destroy do |r|
    r.disc.destroy if r.disc.tracks.empty?
  end

  def length
    audio_file.audio_content.length
  end
end
