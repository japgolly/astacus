class AudioContent < ActiveRecord::Base
  acts_as_unique :only => [:size, :md5, :sha2, :format]

  has_many :audio_files

  attr_readonly :size, :md5, :sha2, :format
  validates :size, :presence => true
  validates :format, :presence => true
  validates :md5, :presence => true, :length => { :is => 16, :tokenizer => lambda {|v| v} }
  validates :sha2, :presence => true, :length => { :is => 64, :tokenizer => lambda {|v| v} }
  validates :bitrate, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :length, :numericality => { :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :samplerate, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }

  def bitrate=(b)
    b= b.round if b.is_a?(Float)
    write_attribute :bitrate, b
  end
end
