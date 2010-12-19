require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  context "index" do
    setup { get :index }
    should respond_with(:success)
  end # Context: index

  context "login" do
    context "with valid credentials" do
      setup { ajax_post :login, :username => 'pleb', :password => 'awww' }
      should respond_with(:success)
      should("log the user in") { assert_equal users(:pleb), cur_user }
      should("reload the page") { assert_rjs_response_action :reload }
    end

    context "with invalid credentials" do
      setup { ajax_post :login, :username => 'pleb', :password => 'awW' }
      should respond_with(:success)
      should("not log the user in") { assert_nil cur_user_id }
      should("alert the user") { assert_rjs_response_action :alert }
    end

    context "with ajax GET" do
      setup { ajax_get :login, :username => 'pleb', :password => 'awww' }
      should redirect_to("root") { root_url }
      should("not log the user in") { assert_nil cur_user_id }
    end

    context "with normal GET" do
      setup { get :login, :username => 'pleb', :password => 'awww' }
      should redirect_to("root") { root_url }
      should("not log the user in") { assert_nil cur_user_id }
    end

    context "with normal POST" do
      setup { post :login, :username => 'pleb', :password => 'awww' }
      should redirect_to("root") { root_url }
      should("not log the user in") { assert_nil cur_user_id }
    end
  end # Context: login

  context "logout" do
    setup {login}

    context "with ajax" do
      setup { ajax_get :logout }
      should respond_with(:success)
      should("log the user out") { assert_nil cur_user_id }
      should("reload the page") { assert_rjs_response_action :reload }
    end

    context "without ajax" do
      setup { get :logout }
      should redirect_to("root") { root_url }
      should("log the user out") { assert_nil cur_user_id }
    end
  end # Context: logout

  def assert_rjs_response_action(action)
    assert_equal 'text/javascript; charset=utf-8', controller.headers['Content-Type'].sub('UTF','utf')
    assert_response_includes 'alert', action == :alert
    assert_response_includes '.reload', action == :reload
  end
end
