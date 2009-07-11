require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  %w[size data mimetype].each{|attr|
    should_validate_presence_of attr
    should_have_readonly_attributes attr
  }
end
