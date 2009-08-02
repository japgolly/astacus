require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  context "Search without any params" do
    setup {get :search}
    should_respond_with :success
    should_render_template :search
    should_assign_to :albums, :class => WillPaginate::Collection
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
end
