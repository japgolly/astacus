class ScannerError < ActiveRecord::Base
  belongs_to :location
  validates :location, :presence => true
  validates :file, :presence => true
  validates :err_msg, :presence => true
end
