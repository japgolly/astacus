require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  context "GET /" do
    setup { get :index }
    should_respond_with :success
  end

end
