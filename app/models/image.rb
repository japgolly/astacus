class Image < ActiveRecord::Base
  attr_readonly :size, :data
  validates_presence_of :size, :data
end
