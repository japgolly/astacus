class Album < ActiveRecord::Base
  belongs_to :albumart, :class_name => "Image"
  belongs_to :artist
  has_many :cds, :order => :order_id

  validates_presence_of :artist, :name
  validates_inclusion_of :year, :allow_nil => true, :in => 0..(Date.today.year+1)
  validates_inclusion_of :original_year, :allow_nil => true, :in => 0..(Date.today.year+1)

  acts_as_unique :except => :albumart_id

  after_destroy do |r|
    r.artist.destroy if r.artist.albums.empty?
  end

  # Updates the albumart for this album based on the albumart in the tags in the
  # album's tracks.
  def update_albumart!
    all= cds.map{|cd| cd.tracks.map{|t| t.audio_file.audio_tags.map(&:albumart)}}.flatten
    all.delete nil
    all= all.inject({}){|h,a| h[a]||=0; h[a]+= 1; h}
    max= all.values.max
    img= all.select{|img,score| score == max}.map{|e| e[0]}.first
    update_attributes! :albumart => img
    self.albumart= img
  end
end
