class AudioContent < ActiveRecord::Base
  acts_as_unique :only => [:size, :md5, :sha2, :format]

  has_many :audio_files

  attr_readonly :size, :md5, :sha2, :format
  validates_presence_of :size, :md5, :sha2, :format
  validates_length_of :md5, :is => 16, :tokenizer => lambda {|v| v}
  validates_length_of :sha2, :is => 64, :tokenizer => lambda {|v| v}
  validates_numericality_of :bitrate, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :length, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :samplerate, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true

  def bitrate=(b)
    b= b.round if b.is_a?(Float)
    write_attribute :bitrate, b
  end
end
