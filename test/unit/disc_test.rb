require 'test_helper'

class DiscTest < ActiveSupport::TestCase
  should_have_many :tracks
  should_belong_to :album
  should_belong_to :album_type
  %w[album order_id].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_numericality_of :order_id

  test "has tracks" do
    assert_equal [tracks(:glass_prison), tracks(:misunderstood)], discs(:'6doit_cd1').tracks
  end

  test "tracks ordered by tn" do
    t= tracks(:glass_prison)
    t.tn= 9
    t.save!
    assert_equal [tracks(:misunderstood), tracks(:glass_prison)], discs(:'6doit_cd1').tracks(true)
    t.tn= 1
    t.save!
    assert_equal [tracks(:glass_prison), tracks(:misunderstood)], discs(:'6doit_cd1').tracks(true)
  end

  test "belongs to album" do
    assert_equal albums(:'6doit'), discs(:'6doit_cd1').album
  end

  test "belongs to album type" do
    assert_equal album_types(:std), discs(:'6doit_cd1').album_type
  end

  context "Deleting a disc" do
    should "not remove the album if other discs reference it" do
      assert_difference 'Disc.count', -1 do
        assert_difference 'Album.count', 0 do
          discs(:'6doit_cd1').destroy
        end
      end
    end

    should "remove the album if no other discs reference it" do
      assert_difference %w[Disc.count Album.count], -1 do
        discs(:ponk).destroy
      end
    end
  end
end
