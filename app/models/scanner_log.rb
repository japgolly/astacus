class ScannerLog < ActiveRecord::Base
  belongs_to :location
  validates :location, :presence => true
  validates :started, :presence => true
  validates :active, :inclusion => { :in => [true, false] }
  validates :files_scanned, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }
  validates :file_count, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true }

  def time_remaining
    return :na unless active?
    return :unknown unless files_scanned and files_scanned > 0
    ((Time.now - started)/files_scanned * (file_count - files_scanned)).seconds
  end
end
