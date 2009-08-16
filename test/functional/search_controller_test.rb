require 'test_helper'

class SearchControllerTest < ActionController::TestCase

  def self.should_pass_common_assertions
    class_eval <<-EOB
      should_respond_with :success
      should_render_template :search
      should_assign_to :albums, :class => WillPaginate::Collection
      should_assign_to :sq, :class => SearchQuery
      should_assign_to :page, :class => Fixnum
    EOB
  end

  context "Search when not logged in" do
    setup {get :search}
    should "not provide download links" do
      assert_select '.discs a[href^=?]', audio_file_url, 0
    end
  end

  context "Search when logged in" do
    setup {login; get :search}
    should "provide download links" do
      assert_select '.discs a[href^=?]', audio_file_url
    end
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

  context "Search with page param is out of range" do
    setup {get :search, :artist => 'a', :page => '100'}
    should "redirect to the same page without the :page param" do
      expected= HashWithIndifferentAccess.new({:controller => 'search', :action => 'search', :artist => 'a'})
      actual= HashWithIndifferentAccess.new(response.redirected_to)
      assert_equal expected, actual
    end
  end

  context "The search query form" do
    should "have the current boolean option selected" do
      # No param
      get :search
      assert_select '#search_query_form select[name=albumart] option[selected]', 1 do
        assert_select '[value=?]', ''
      end
      # With params
      ['', '0', '1'].each{|param|
        get :search, :albumart => param
        assert_select '#search_query_form select[name=albumart] option[selected]', 1 do
          assert_select '[value=?]', param
        end
      }
    end
  end # context "The search query form"

  context "Search with invalid params" do
    setup {get :search, :discs => 'omg1', :year => 'omg2'}
    should_respond_with :success
    should_render_template :search
    should_assign_to :sq, :class => SearchQuery
    should "contain validation error messages" do
      assert_select '#sq_errors' do
        assert_select 'li', 2
      end
    end
    should "still populate the search query form" do
      assert_select '#discs[value=?]', 'omg1'
      assert_select '#year[value=?]', 'omg2'
    end
  end
end
