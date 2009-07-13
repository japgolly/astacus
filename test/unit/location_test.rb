require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  should_validate_presence_of :label
  should_validate_presence_of :dir
  should_have_readonly_attributes :dir
  should_validate_uniqueness_of :dir
end
