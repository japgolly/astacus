require 'test_helper'

class SearchQueryTest < ActiveSupport::TestCase
  context "A search query object" do
    setup {@sq= SearchQuery.new}

    should "be able to combine joins and includes" do
      j= :joins
      assert_equal({j => [:artist]}, @sq.add_associations!({}, j, :artist))
      assert_equal({j => [:x,:artist]}, @sq.add_associations!({j => :x}, j, :artist))
      assert_equal({j => [:x,:artist]}, @sq.add_associations!({j => [:x,:artist]}, j, :artist))
      assert_equal({j => [:a => [:b]]}, @sq.add_associations!({}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, @sq.add_associations!({j => :a}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, @sq.add_associations!({j => [:a]}, j, :a => :b))
      assert_equal({j => [:a => [:b]]}, @sq.add_associations!({j => [:a => [:b]]}, j, :a => :b))
      assert_equal({j => [:a => [:c,:b]]}, @sq.add_associations!({j => [:a => [:c]]}, j, :a => :b))
      assert_equal({j => [:a => [:b,:c]]}, @sq.add_associations!({j => [:a => [:b, :c]]}, j, :a => :b))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, @sq.add_associations!({j => [{:a=>[{:b=>[:x,:y]},:c]},:d]}, j, :a=>{:b=>:z}))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, @sq.add_associations!({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, j, :a=>{:b=>:y}))
      assert_equal({j => [{:a=>[{:b=>[:y,:z,{:x=>[:xx]}]},:c]},:d]}, @sq.add_associations!({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d]}, j, :a=>{:b=>{:x=>:xx}}))
      assert_equal({j => [{:a=>[{:b=>[:x,:y,:z]},:c]},:d,:q1,:q2]}, @sq.add_associations!({j => [{:a=>[{:b=>[:x,:y]},:c]},:d]}, j, [:q1,:q2,{:a=>{:b=>:z}}]))
    end
  end
end
