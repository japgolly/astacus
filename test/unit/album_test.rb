require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  should_belong_to :albumart
  should_belong_to :artist
  should_have_many :cds
  %w[artist name].each{|attr|
    should_validate_presence_of attr
  }
  %w[year original_year].each{|attr|
    should_ensure_value_in_range attr, 0..(Date.today.year+1)
  }

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

  context "Albums" do
    should "be created if doesnt exist yet" do
      artist= Artist.first
      album_name= 'woteva'
      a= nil
      assert_difference 'Album.count', +1 do
        a= Album.find_identical_or_create!(:artist => artist, :name => album_name)
      end
      assert !a.new_record?
      assert_equal album_name, a.name
    end

    should "be reused if already exists" do
      dt= artists(:dream_theater)
      a= nil
      assert_difference 'Album.count', 0 do
        a= Album.find_identical_or_create!(:artist => dt, :name => 'Six Degrees Of Inner Turbulence', :year => 2002)
      end
      assert !a.new_record?
      assert_equal dt, a.artist
      assert_equal 'Six Degrees Of Inner Turbulence', a.name
    end

    should "not be reused when the artist differs" do
      ponk= albums(:ponk)
      assert_difference 'Album.count', +1 do
        attr= ponk.attributes.merge :artist_id => artists(:dream_theater).id
        a= Album.find_identical_or_create!(attr)
      end
    end

    should "be reused when the albumart differs" do
      img= Image.create(:size => 1, :data => 'a', :mimetype => 'a')
      album= albums(:'6doit')
      album.albumart= img
      album.save!

      dt= artists(:dream_theater)
      a= nil
      assert_difference 'Album.count', 0 do
        a= Album.find_identical_or_create!(:artist => dt, :name => 'Six Degrees Of Inner Turbulence', :year => 2002)
      end
      assert !a.new_record?
      assert_equal img, a.albumart
    end

    should "use the most common albumart available" do
      af= audio_files(:the_requiem)
      i1= Image.create(:size => 1, :data => 'a', :mimetype => 'a')
      i2= Image.create(:size => 1, :data => 'a', :mimetype => 'a')
      a= albums(:ponk)
      a.update_albumart!
      assert_nil a.reload.albumart

      4.times{ create_new_audio_tag af, i1 }
      a.update_albumart!
      assert_equal i1, a.reload.albumart

      3.times{ create_new_audio_tag af, i2 }
      a.update_albumart!
      assert_equal i1, a.reload.albumart

      2.times{ create_new_audio_tag af, i2 }
      a.update_albumart!
      assert_equal i2, a.reload.albumart

      AudioTag.delete_all
      a.update_albumart!
      assert_nil a.reload.albumart
    end
  end

  def create_new_audio_tag(af, image)
    AudioTag.create(:audio_file => af, :format => 'id3', :offset => 0, :data => 'blah', :albumart => image)
  end
end
