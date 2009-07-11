class Image < ActiveRecord::Base
  attr_readonly :size, :data, :mimetype
  validates_presence_of :size, :data, :mimetype
  acts_as_unique

#  before_save do |img|
#    img.size= img.data.size if img.data
#  end
end
