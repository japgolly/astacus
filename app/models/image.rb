class Image < ActiveRecord::Base
  attr_readonly :size, :data, :mimetype
  validates_presence_of :size, :data, :mimetype
  has_many :audio_tags, :foreign_key => 'albumart_id'
  has_many :albums, :foreign_key => 'albumart_id'
  acts_as_unique :secondary => :data

  def before_validation_on_create
    self.size= data.size if attribute_present?(:data)
  end

  def file_extention
    return 'jpg' if mimetype == 'image/jpeg'
    mimetype.sub /^image\//, ''
  end
end
