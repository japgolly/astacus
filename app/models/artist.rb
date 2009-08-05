class Artist < ActiveRecord::Base
  has_many :albums
  has_many :va_tracks, :foreign_key => 'track_artist_id', :class_name => 'Track'
  validates_presence_of :name
  validates_uniqueness_of :name, :allow_blank => false, :allow_nil => true
  acts_as_unique

  def in_use?
    !albums.empty? or !va_tracks.empty?
  end
end
