class Image < ActiveRecord::Base
  attr_readonly :size, :data, :mimetype
  validates_presence_of :size, :data, :mimetype
  has_many :audio_tags, :foreign_key => 'albumart_id'
  has_many :albums, :foreign_key => 'albumart_id'
  acts_as_unique :secondary => :data

  def data=(data)
    write_attribute :size, data ? data.size : nil
    write_attribute :data, data
  end

  def file_extention
    return 'jpg' if mimetype == 'image/jpeg'
    mimetype.sub /^image\//, ''
  end
end
