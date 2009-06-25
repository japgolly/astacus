class AudioTag < ActiveRecord::Base
  belongs_to :audio_file
  validates_presence_of :audio_file, :format, :offset, :data
  validates_numericality_of :offset, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
end
