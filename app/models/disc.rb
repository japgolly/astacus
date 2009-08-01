class Disc < ActiveRecord::Base
  has_many :tracks, :order => :tn
  belongs_to :album
  belongs_to :album_type

  validates_presence_of :album, :order_id
  validates_numericality_of :order_id, :only_integer => true, :allow_nil => true

  acts_as_unique

  after_destroy do |r|
    r.album.destroy if r.album.discs.empty?
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
