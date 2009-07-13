class Location < ActiveRecord::Base
  attr_readonly :dir
  validates_presence_of :dir, :label
  validates_uniqueness_of :dir
end
