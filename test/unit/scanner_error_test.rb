require 'test_helper'

class ScannerErrorTest < ActiveSupport::TestCase
  should_belong_to :location
  %w[location file err_msg].each{|attr| should_validate_presence_of attr}
end
