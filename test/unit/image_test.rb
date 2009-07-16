require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  %w[size data mimetype].each{|attr|
    should_validate_presence_of attr
    should_have_readonly_attributes attr
  }
  should_have_many :albums
  should_have_many :audio_tags

  def test_acts_as_unique_without_setting_size
    assert_difference 'Image.count', +1 do
      Image.find_identical_or_create!(:data => 'abc', :mimetype => 'a')
    end
    assert_difference 'Image.count', 0 do
      Image.find_identical_or_create!(:data => 'abc', :mimetype => 'a')
    end
  end

  def test_file_extention
    assert_equal 'jpg', Image.new(:mimetype => 'image/jpeg').file_extention
    assert_equal 'gif', Image.new(:mimetype => 'image/gif').file_extention
    assert_equal 'png', Image.new(:mimetype => 'image/png').file_extention
  end
end
