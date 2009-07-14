require 'test_helper'

class LocationsControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_response :success
  end

  def test_create_good
    assert_difference 'Location.count' do
      xml_http_request :post, :create, "location"=>{"label"=>"aegg", "dir"=>"asd234"}
    end
    assert_response :success
    assert_response_doesnt_match /alert/
  end

  def test_create_bad
    assert_no_difference 'Location.count' do
      xml_http_request :post, :create, "location"=>{"label"=>"", "dir"=>"asd234"}
    end
    assert_response :success
    assert_response_matches /alert/
  end
end
