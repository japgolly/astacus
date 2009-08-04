require 'test_helper'
require 'search_query_filter_results'

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

  include SearchQueryFilterResults
  ALBUM_FILTERS.each{|params,albums|
    class_eval <<-EOB
      context "Search filtered by #{params.map{|k,v|"#{k} #{v}"}.sort.join ' and '}" do
        setup {get :search, #{params.inspect}}
        should_pass_common_assertions
        should "filter its results appropriately" do
          assert_same_named_elements [#{albums.map{|a| "albums('#{a}')"}.join(',')}], assigns(:albums)
        end
      end
    EOB
  }

  context "Search with page param is out of range" do
    setup {get :search, :artist => 'a', :page => '100'}
    should_redirect_to('same page without the :page param') {
      {:artist => 'a', :page => nil}
    }
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
end
