class Image < ActiveRecord::Base
  attr_readonly :size, :data, :mimetype
  validates :size, :data, :mimetype, :presence => true
  has_many :audio_tags, :foreign_key => 'albumart_id'
  has_many :albums, :foreign_key => 'albumart_id'
  acts_as_unique :secondary => :data

  after_destroy do |r|
    r.albums.each{|a| a.update_albumart! r.id}
  end

  def data=(data)
    write_attribute :size, data ? data.size : nil
    write_attribute :data, data
  end

  def file_extention
    return 'jpg' if mimetype == 'image/jpeg'
    mimetype.sub /^image\//, ''
  end
end

