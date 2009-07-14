class ScannerLog < ActiveRecord::Base
  belongs_to :location
  validates_presence_of :started, :location
  validates_inclusion_of :active, :in => [true, false]
  validates_numericality_of :files_scanned, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :file_count, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
end
