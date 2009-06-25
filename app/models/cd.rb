class Cd < ActiveRecord::Base
  has_many :tracks, :order => :tn
  belongs_to :album
  belongs_to :album_type

  validates_presence_of :album, :order_id
  validates_numericality_of :order_id, :only_integer => true, :allow_nil => true
end
