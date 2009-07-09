class Album < ActiveRecord::Base
  belongs_to :albumart, :class_name => "Image"
  belongs_to :artist
  has_many :cds, :order => :order_id

  validates_presence_of :artist, :name
  validates_inclusion_of :year, :allow_nil => true, :in => 0..(Date.today.year+1)
  validates_inclusion_of :original_year, :allow_nil => true, :in => 0..(Date.today.year+1)

  acts_as_unique
end
