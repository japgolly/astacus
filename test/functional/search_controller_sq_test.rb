require 'test_helper'
require 'search_query_filter_results'

class SearchControllerSqTest < ActionController::TestCase
  tests SearchController
  include SearchQueryFilterResults

  ALBUM_FILTERS.each{|params,albums|
    class_eval <<-EOB
      context "Search filtered by #{params.map{|k,v|"#{k} #{v}"}.sort.join ' and '}" do
        setup {get :search, #{params.inspect}}
        should respond_with(:success)
        should render_template(:search)
        should "filter its results appropriately" do
          assert_same_named_elements [#{albums.map{|a| "albums('#{a}')"}.join(',')}], assigns(:albums)
        end
      end
    EOB
  }
end
