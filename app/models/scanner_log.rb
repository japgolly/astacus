class ScannerLog < ActiveRecord::Base
  belongs_to :location
  validates_presence_of :started, :active, :location
  validates_numericality_of :file_count, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true
end
