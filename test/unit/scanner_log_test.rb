require 'test_helper'

class ScannerLogTest < ActiveSupport::TestCase
  should_belong_to :location
  %w[started location].each{|a| should_validate_presence_of a.to_sym}
  should_validate_positive_numericality_of :files_scanned
  should_validate_positive_numericality_of :file_count
  should_allow_values_for :active, true, false

  def test_should_validate_presence_of_active_flag
    sl= ScannerLog.new
    assert !sl.valid?
    assert_not_equal sl.errors[:active], []
  end
end
