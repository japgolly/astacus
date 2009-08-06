require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  TOTAL_FILESIZE= \
    19989119 + # glass_prison
    13507820 + # misunderstood
    8427118 + # about_to_crash
    11494512 + # the_requiem
    3108860 + # apsog_i
    5179014 + # apsog_ii
    1712044 + # apsog_x
    4875580 + # apsog_xi
    10834006 + # apsog_xii
    30106094 + # the_ivory_gate_of_dreams
    11880343 + # the_eleventh_hour
    98897 + # blackest_eyes
    98797 + # trains
    99839 + # lips_of_ashes
    101371 + # the_sound_of_muzak
    215037 + # silsila_ye_chaahat_ka
    9761101 + # maar_daala
    11319985 + # bairi_piya
    11537513 + # kaahe_chhed_mohe
  0#end TOTAL_FILESIZE

  TOTAL_LENGTH= \
    834 + # glass_prison
    564 + # misunderstood
    352 + # about_to_crash
    372 + # the_requiem
    129.463 + # apsog_i
    215.719 + # apsog_ii
    71.262 + # apsog_x
    203.076 + # apsog_xi
    451.318 + # apsog_xii
    1254.35 + # the_ivory_gate_of_dreams
    494.942 + # the_eleventh_hour
    263.654 + # blackest_eyes
    356.467 + # trains
    279.301 + # lips_of_ashes
    299.154 + # the_sound_of_muzak
    324.885 + # silsila_ye_chaahat_ka
    278.256 + # maar_daala
    321.907 + # bairi_piya
    322.403 + # kaahe_chhed_mohe
  0#end TOTAL_LENGTH

  #=============================================================================

  context "stats/index" do
    context "with no params" do
      setup do
        AudioContent.update_all 'bitrate=10'
        AudioContent.update audio_content(:glass_prison).id, :bitrate => 1234
        get :index
        @stats= assigns(:stats)
      end
      should_respond_with :success
      should_render_template 'index'
      should "calculate the stats correctly" do
        ac_count= AudioContent.count
        assert_equal files=19, @stats[:files]
        assert_equal TOTAL_FILESIZE, @stats[:filesize]
        assert_equal artists=5, @stats[:artists]
        assert_equal albums=5, @stats[:albums]
        assert_equal 1, @stats[:va_albums]
        assert_equal 2, @stats[:multiple_disc_albums]
        assert_equal discs=8, @stats[:discs]
        assert_equal tracks=19, @stats[:tracks]
        assert_in_delta TOTAL_LENGTH, @stats[:length], 0.01
        assert_in_delta (1234 + 10*(ac_count-1)).to_f / ac_count, @stats[:avg_bitrate], 0.1
        assert_equal albums_waa=2, @stats[:albums_without_albumart]

        assert_in_delta TOTAL_LENGTH / tracks, @stats[:avg_length], 0.001
        assert_in_delta TOTAL_FILESIZE.to_f / files, @stats[:avg_filesize], 0.001
        assert_in_delta albums.to_f / artists.to_f, @stats[:avg_albums_p_artist], 0.001
        assert_in_delta tracks.to_f / artists.to_f, @stats[:avg_tracks_p_artist], 0.001
        assert_in_delta tracks.to_f / discs.to_f, @stats[:avg_tracks_p_disc], 0.001
        assert_equal albums-albums_waa, @stats[:albums_with_albumart]
      end
    end # Context: with no params
  end # Context: stats/index
end
