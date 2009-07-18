class Track < ActiveRecord::Base
  belongs_to :cd
  belongs_to :audio_file
  has_and_belongs_to_many :audio_tags, :uniq => true

  validates_presence_of :cd, :audio_file, :name
  validates_numericality_of :tn, :only_integer => true, :allow_nil => true

  acts_as_unique

  after_destroy do |r|
    r.cd.destroy if r.cd.tracks.empty?
  end
end
