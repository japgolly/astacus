require 'test_helper'
require 'search_query_filter_results'

class SearchQueryTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_presence_of :params

  include SearchQueryFilterResults
  ALBUM_FILTERS.each{|params,albums|
    class_eval <<-EOB
      test "filter by #{params.map{|k,v|"#{k} #{v}"}.sort.join ' and '}" do
        sq= SearchQuery.new(:params => #{params.inspect}, :name => 'omfg')
        assert sq.valid?, "SQ should be valid. Errors:#\{sq.errors.full_messages.join "\n  "}"
        options= {:select => 'distinct albums.*'}
        options.merge! sq.to_find_options
        albums= Album.find(:all,options)
        assert_same_named_elements [#{albums.map{|a| "albums('#{a}')"}.join(',')}], albums
      end
    EOB
  }

  context "A search query object" do
    should "clean up params objects on assignment" do
      {
        {} => {},
        {:book=>'1'} => {},
        {:book=>'1','artist'=>'2',:album=>'3'} => {:artist=>'2',:album=>'3'},
        {:book=>'1','artist'=>'2',:album=>nil} => {:artist=>'2'},
      }.each{|before,after|
        assert_equal after, SearchQuery.new(:params => before).params
      }
    end
    should "clean up int params" do
      {
        '1996' => '1996',
        ' 1996 ' => '1996',
        ' 1996 -  2002  ,2009' => '1996-2002, 2009',
        '2001,2003,2010-2008' => '2001, 2003, 2008-2010',
        '2001,2003,2009-2009' => '2001, 2003, 2009',
      }.each{|before,after|
        before= {:year => before}
        after= {:year => after}
        assert_equal after, SearchQuery.new(:params => before).params
      }
    end
    should "clean up taglist params" do
      {
        'abc' => 'abc',
        '  abc,bef ' => 'abc bef',
        ' ! abc bef' => '! abc bef',
        'abc,bef abc,ert' => 'abc bef ert',
        '!abc,bef,abc ert' => '! abc bef ert',
      }.each{|before,after|
        before= {:location => before}
        after= {:location => after}
        assert_equal after, SearchQuery.new(:params => before).params
      }
    end

    should "be able to combine joins and includes" do
      j= :joins
      assert_equal({j => [:artist]}, SearchQuery.add_associations!({}, j, :artist))
      assert_equal({j => [:x,:artist]}, SearchQuery.add_associations!({j => :x}, j, :artist))
      assert_equal({j => [:x,:artist]}, SearchQuery.add_associations!({j => [:x,:artist]}, j, :artist))
      assert_equal({j => [:a => [:b]]}, SearchQuery.add_associations!({}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, SearchQuery.add_associations!({j => :a}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, SearchQuery.add_associations!({j => [:a]}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, SearchQuery.add_associations!({j => [:a => [:b]]}, j, :a => :b))
      assert_equal({j => [:a => [:c,:b]]}, SearchQuery.add_associations!({j => [:a => [:c]]}, j, :a => :b))
      assert_equal({j => [:a => [:b,:c]]}, SearchQuery.add_associations!({j => [:a => [:b, :c]]}, j, :a => :b))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, SearchQuery.add_associations!({j => [{:a=>[{:b=>[:x,:y]},:c]},:d]}, j, :a=>{:b=>:z}))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, SearchQuery.add_associations!({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, j, :a=>{:b=>:y}))
      assert_equal({j => [{:a=>[{:b=>[:y,:z,{:x=>[:xx]}]},:c]},:d]}, SearchQuery.add_associations!({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, j, :a=>{:b=>{:x=>:xx}}))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d,:q1,:q2]}, SearchQuery.add_associations!({j => [{:a=>[{:b=>[:x,:y]},:c]},:d]}, j, [:q1,:q2,{:a=>{:b=>:z}}]))
    end

    should "validate boolean fields" do
      assert_param_validation_fails({
        :on => %w[albumart],
        :with => %w[a 10 01],
      })
    end

    should "validate integer fields" do
      assert_param_validation_fails({
        :on => %w[year discs],
        :with => %w[abc 1990-- 1-2-3 3>4],
      })
    end

    should "validate the location param" do
      assert_param_validation_fails({
        :on => %w[location],
        :with => %w[xxx cdownloads man],
      })
    end
  end

  def assert_param_validation_fails(options)
    options.assert_valid_keys(:on, :with)
    options[:on].each {|field|
      options[:with].each {|value|
        sq= SearchQuery.new(:params => {field => value})
        assert !sq.valid?, "SearchQuery shouldn't pass validation."
        assert sq.errors[field][0], "Validation error expected on #{field.inspect}"
        assert sq.errors[field].size, 1
      }
    }
  end
end
