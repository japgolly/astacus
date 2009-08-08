require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  content "GET /" do
    should_respond_with :success
  end

end
