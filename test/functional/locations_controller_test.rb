require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_response :success
  end

  def test_show
    loc= locations(:main)
    xml_http_request :get, :show, :id => loc.id
    assert_response :success
    assert_response_includes loc.label
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

  def test_edit
    loc= locations(:main)
    xml_http_request :get, :edit, :id => loc.id
    assert_response :success
    assert_response_includes loc.label
    assert_response_includes '<form'
  end

  def test_update_good
    loc= locations(:main)
    xml_http_request :post, :update, :id => loc.id, :location => {:label => 'sweet'}
    assert_response :success
    assert_response_doesnt_match /alert/
    loc.reload
    assert_equal 'sweet', loc.label
  end

  def test_update_bad
    loc= locations(:main)
    prev_label= loc.label
    xml_http_request :post, :update, :id => loc.id, :location => {:label => ''}
    assert_response :success
    assert_response_matches /alert/
    loc.reload
    assert_equal prev_label, loc.label
  end

end
