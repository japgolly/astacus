require 'test_helper'

class AlbumTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).case_insensitive
  should_not_allow_values_for :name, '', '   ', :message => "can't be blank"
end
