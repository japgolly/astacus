require 'test_helper'

class AlbumTypeTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_uniqueness_of :name, :case_sensitive => false
  should_not_allow_values_for :name, '', '   ', :message => "can't be blank"
end
