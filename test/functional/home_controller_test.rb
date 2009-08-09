require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  context "index" do
    setup { get :index }
    should_respond_with :success
  end # Context: index

  context "login" do
    context "with valid credentials" do
      setup { ajax_post :login, :username => 'pleb', :password => 'awww' }
      should_respond_with :success
      should("log the user in") { assert_equal users(:pleb), cur_user }
      should("reload the page") { TODO }
    end

    context "with invalid credentials" do
      setup { ajax_post :login, :username => 'pleb', :password => 'awW' }
      should_respond_with :success
      should("not log the user in") { assert_nil cur_user_id }
      should("alert the user") { TODO }
    end
  end # Context: login

  context "logout" do
    setup { ajax_post :logout }
    should_respond_with :success
    should("log the user out") { assert_nil cur_user_id }
    should("reload the page") { TODO }
  end # Context: logout
end
