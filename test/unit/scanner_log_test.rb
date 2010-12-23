require 'test_helper'

class ScannerLogTest < ActiveSupport::TestCase
  should belong_to(:location)
  %w[started location].each{|a| should validate_presence_of(a.to_sym)}
  should_validate_positive_numericality_of :files_scanned
  should_validate_positive_numericality_of :file_count
  should allow_value(true).for(:active)
  should allow_value(false).for(:active)

  def test_should_validate_presence_of_active_flag
    sl= ScannerLog.new
    assert !sl.valid?
    assert_not_equal sl.errors[:active], []
  end
end
