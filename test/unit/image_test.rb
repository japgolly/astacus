require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  %w[size data mimetype].each{|attr|
    should validate_presence_of(attr)
    should have_readonly_attribute(attr)
  }
  should have_many(:albums)
  should have_many(:audio_tags)

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

  def test_acts_as_unique_secondary
    common= {:size => 4, :mimetype => 'x'}
    i1= Image.create common.merge(:data => 'aaaa')
    i2= Image.create common.merge(:data => 'bbbb')
    assert_equal i1, Image.find_identical(Image.new(common.merge(:data => 'aaaa')))
    assert_equal i2, Image.find_identical(Image.new(common.merge(:data => 'bbbb')))
    assert_nil Image.find_identical(Image.new(common.merge(:data => 'cccc')))
  end
end
