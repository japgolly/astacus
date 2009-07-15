class ScannerError < ActiveRecord::Base
  belongs_to :location
  validates_presence_of :location, :file, :err_msg
end
