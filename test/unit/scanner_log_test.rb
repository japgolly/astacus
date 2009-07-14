require 'test_helper'

class ScannerLogTest < ActiveSupport::TestCase
  should_belong_to :location
  %w[started active location].each{|a| should_validate_presence_of a.to_sym}
  should_validate_positive_numericality_of :file_count
end
