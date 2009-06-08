require 'test_helper'

class AlbumTest < ActiveSupport::TestCase

  test "has cds" do
    assert_equal [cds(:'6doit_cd1'), cds(:'6doit_cd2')], albums(:'6doit').cds
  end

  test "cds ordered" do
    cd= cds(:'6doit_cd1')
    cd.order_id= 2
    cd.save!
    assert_equal [cds(:'6doit_cd2'), cds(:'6doit_cd1')], albums(:'6doit').cds(true)
    cd.order_id= 0
    cd.save!
    assert_equal [cds(:'6doit_cd1'), cds(:'6doit_cd2')], albums(:'6doit').cds(true)
  end

  test "belongs to artist" do
    assert_equal artists(:dream_theater), albums(:'6doit').artist
  end
end
