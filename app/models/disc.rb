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
end
