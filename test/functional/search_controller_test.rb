require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  def self.should_pass_common_assertions
    class_eval <<-EOB
      should_respond_with :success
      should_render_template :search
      should_assign_to :albums, :class => WillPaginate::Collection
    EOB
  end

  context "Search without any params" do
    setup {get :search}
    should_pass_common_assertions
    should "contain all albums" do
      assert_same_named_elements Album.find(:all), assigns(:albums)
    end
    should "render album data" do
      assert_select '.albumart img'
      assert_response_includes 'Disc 1'
      assert_response_includes 'Disc 2'
      assert_response_includes 'Disc 3'
      assert_response_includes 'Still Life'
      assert_response_includes 'A Pleasant Shade of Gray XII'
      assert_response_includes 'The Eleventh Hour'
      assert_response_includes '192 kbps'
      assert_response_includes 'The Sound Of Muzak'
      assert_response_includes '4:59' # length of The Sound Of Muzak
    end
  end

  context "Search filtered by artist" do
    setup {get :search, :artist => 'RCupIN'}
    should_pass_common_assertions
    should "filter its results appropriately" do
      assert_same_named_elements artists(:porcupine_tree).albums, assigns(:albums)
    end
  end

  context "Search filtered by album name" do
    setup {get :search, :album => 'in'}
    should_pass_common_assertions
    should "filter its results appropriately" do
      assert_same_named_elements [albums(:'6doit'),albums(:in_absentia)], assigns(:albums)
    end
  end

  context "Search filtered by artist and album name" do
    setup {get :search, :album => 'in', :artist => 'dream'}
    should_pass_common_assertions
    should "filter its results appropriately" do
      assert_same_named_elements [albums(:'6doit')], assigns(:albums)
    end
  end

  context "Search filtered by track name" do
    setup {get :search, :track => 'y'}
    should_pass_common_assertions
    should "filter its results appropriately" do
      assert_same_named_elements [albums(:still_life),albums(:in_absentia)], assigns(:albums)
    end
  end

  def assert_same_named_elements(expected, actual)
    assert_same_elements expected.map(&:name), actual.map(&:name)
    assert_same_elements expected, actual
  end
end
