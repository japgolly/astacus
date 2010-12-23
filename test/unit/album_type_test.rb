require 'test_helper'

class AlbumTypeTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name).case_insensitive
  should_not allow_value('').for(:name).with_message("can't be blank")
  should_not allow_value('   ').for(:name).with_message("can't be blank")
end
