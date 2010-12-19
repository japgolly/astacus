require 'test_helper'

class ScannerErrorTest < ActiveSupport::TestCase
  should belong_to(:location)
  %w[location file err_msg].each{|attr| should validate_presence_of(attr)}
end
