class Album < ActiveRecord::Base
  belongs_to :albumart, :class_name => "Image"
  belongs_to :artist
  has_many :discs, :order => 'discs.order_id, discs.name'

  validates_presence_of :artist, :name
  validates_inclusion_of :year, :allow_nil => true, :in => 0..(Date.today.year+1)
  validates_inclusion_of :original_year, :allow_nil => true, :in => 0..(Date.today.year+1)

  acts_as_unique :except => [:albumart_id, :discs_count]

  after_destroy do |r|
    r.artist.destroy unless r.artist.in_use?
  end

  module Joins
    JOIN_TO_AR= :artist
    JOIN_TO_DISCS= :discs
    JOIN_TO_TRACKS= {:discs => :tracks}
    JOIN_TO_AF= {:discs => {:tracks => :audio_file}}
    JOIN_TO_AC= {:discs => {:tracks => {:audio_file => :audio_content}}}
    JOIN_TO_LOC= {:discs => {:tracks => {:audio_file => :location}}}
  end
  extend Joins
  include Joins

  def in_use?
    discs_count != 0
  end

  # Updates the albumart for this album based on the albumart in the tags in the
  # album's tracks.
  def update_albumart!(illegal_albumart_id= nil)
    all= discs.map{|d| d.tracks.map{|t| t.audio_file.audio_tags.map(&:albumart)}}.flatten
    all.delete nil
    all.delete illegal_albumart_id if illegal_albumart_id
    all= all.inject({}){|h,a| h[a]||=0; h[a]+= 1; h}
    max= all.values.max
    img= all.select{|img,score| score == max}.map{|e| e[0]}.first
    update_attributes! :albumart => img
    self.albumart= img
  end
end
