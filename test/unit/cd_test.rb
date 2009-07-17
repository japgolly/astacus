require 'test_helper'

class CdTest < ActiveSupport::TestCase
  should_have_many :tracks
  should_belong_to :album
  should_belong_to :album_type
  %w[album order_id].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_numericality_of :order_id

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

  context "Deleting a cd" do
    should "not remove the album if other cds reference it" do
      assert_difference 'Cd.count', -1 do
        assert_difference 'Album.count', 0 do
          cds(:'6doit_cd1').destroy
        end
      end
    end

    should "remove the album if no other cds reference it" do
      assert_difference %w[Cd.count Album.count], -1 do
        cds(:ponk).destroy
      end
    end
  end
end
