class Track < ActiveRecord::Base
  belongs_to :disc
  belongs_to :audio_file
  belongs_to :track_artist, :class_name => 'Artist'
  has_and_belongs_to_many :audio_tags, :uniq => true

  validates_presence_of :disc, :audio_file, :name
  validates_numericality_of :tn, :only_integer => true, :allow_nil => true

  acts_as_unique

  after_destroy do |r|
    disc= r.disc
    track_artist= r.track_artist
    log_vars 'Track.after_destroy', 'TRACK' => r.inspect, 'DISC' => disc.inspect, 'DISC TRACKS' => (disc && disc.tracks.inspect) if logger.debug?
    disc.destroy if disc and disc.tracks.empty?
    track_artist.destroy if track_artist and !track_artist.in_use?
  end

  def bitrate
    audio_file.audio_content.bitrate
  end

  def length
    audio_file.audio_content.length
  end

  def size
    audio_file.size
  end
end
