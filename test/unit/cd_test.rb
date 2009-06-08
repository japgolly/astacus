require 'test_helper'

class CdTest < ActiveSupport::TestCase

  test "has tracks" do
    assert_equal [tracks(:glass_prison), tracks(:misunderstood)], cds(:'6doit_cd1').tracks
  end

  test "tracks ordered by tn" do
    t= tracks(:glass_prison)
    t.tn= 9
    t.save!
    assert_equal [tracks(:misunderstood), tracks(:glass_prison)], cds(:'6doit_cd1').tracks(true)
    t.tn= 1
    t.save!
    assert_equal [tracks(:glass_prison), tracks(:misunderstood)], cds(:'6doit_cd1').tracks(true)
  end

  test "belongs to album" do
    assert_equal albums(:'6doit'), cds(:'6doit_cd1').album
  end

  test "belongs to album type" do
    assert_equal album_types(:std), cds(:'6doit_cd1').album_type
  end
end
