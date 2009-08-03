class Disc < ActiveRecord::Base
  has_many :tracks, :order => :tn
  belongs_to :album, :counter_cache => true
  belongs_to :album_type

  validates_presence_of :album, :order_id
  validates_numericality_of :order_id, :only_integer => true, :allow_nil => true

  acts_as_unique

  after_destroy do |r|
    album= r.album(true)
    log_vars 'Disc.after_destroy', 'DISC' => r.inspect, 'ALBUM' => album.inspect, 'ALBUM DISCS' => (album && album.discs.inspect) if logger.debug?
    album.destroy if album and album.discs_count == 0
  end

  # TODO Test these when we get better fixtures
  def length
    tracks.inject(0.0){|sum,t| sum + t.length}
  end

  def size
    tracks.inject(0){|sum,t| sum + t.size}
  end

  def formats
    tracks.map{|t| t.audio_file.audio_content.format}.sort.uniq
  end

  def avg_bitrate
    uniq= {}
    bitrates= tracks.map{|t|
      bitrate= t.bitrate
      uniq[bitrate]= 1
      bitrate.to_f * t.length
    }
    return uniq.keys[0] if uniq.size == 1
    (bitrates.inject(0.0){|sum,b| sum + b } / length).round
  end
end
