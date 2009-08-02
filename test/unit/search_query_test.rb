require 'test_helper'

class SearchQueryTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_validate_presence_of :params

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
  end
end
