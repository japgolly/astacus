require 'test_helper'

class StatsControllerTest < ActionController::TestCase

  # ------------- Filesize -------------

  PONK_FILESIZE= 11494512 # the_requiem

  IN_ABSENTIA_FILESIZE= \
    98897 + # blackest_eyes
    98797 + # trains
    99839 + # lips_of_ashes
    101371  # the_sound_of_muzak

  TOTAL_FILESIZE= PONK_FILESIZE + IN_ABSENTIA_FILESIZE +
    19989119 + # glass_prison
    13507820 + # misunderstood
    8427118 + # about_to_crash
    3108860 + # apsog_i
    5179014 + # apsog_ii
    1712044 + # apsog_x
    4875580 + # apsog_xi
    10834006 + # apsog_xii
    30106094 + # the_ivory_gate_of_dreams
    11880343 + # the_eleventh_hour
    215037 + # silsila_ye_chaahat_ka
    9761101 + # maar_daala
    11319985 + # bairi_piya
    11537513 + # kaahe_chhed_mohe
    33956044 + # close_to_the_edge
    8526359 + # time_and_a_word
  0#end TOTAL_FILESIZE

  # ------------- Length -------------

  PONK_LENGTH= 372 # the_requiem

  IN_ABSENTIA_LENGTH= \
    263.654 + # blackest_eyes
    356.467 + # trains
    279.301 + # lips_of_ashes
    299.154   # the_sound_of_muzak

  TOTAL_LENGTH= PONK_LENGTH + IN_ABSENTIA_LENGTH +
    834 + # glass_prison
    564 + # misunderstood
    352 + # about_to_crash
    129.463 + # apsog_i
    215.719 + # apsog_ii
    71.262 + # apsog_x
    203.076 + # apsog_xi
    451.318 + # apsog_xii
    1254.35 + # the_ivory_gate_of_dreams
    494.942 + # the_eleventh_hour
    324.885 + # silsila_ye_chaahat_ka
    278.256 + # maar_daala
    321.907 + # bairi_piya
    322.403 + # kaahe_chhed_mohe
    18*60+46 + # close_to_the_edge
    4*60+22 + # time_and_a_word
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
        assert_equal files=21, @stats[:files]
        assert_equal TOTAL_FILESIZE, @stats[:filesize]
        assert_equal artists=6, @stats[:artists]
        assert_equal albums=7, @stats[:albums]
        assert_equal 1, @stats[:va_albums]
        assert_equal 2, @stats[:multiple_disc_albums]
        assert_equal discs=10, @stats[:discs]
        assert_equal tracks=21, @stats[:tracks]
        assert_in_delta TOTAL_LENGTH, @stats[:length], 0.01
        assert_in_delta (1234 + 10*(ac_count-1)).to_f / ac_count, @stats[:avg_bitrate], 0.1
        assert_equal albums_waa=4, @stats[:albums_without_albumart]

        assert_in_delta TOTAL_LENGTH / tracks, @stats[:avg_length], 0.001
        assert_in_delta TOTAL_FILESIZE.to_f / files, @stats[:avg_filesize], 0.001
        assert_in_delta albums.to_f / artists.to_f, @stats[:avg_albums_p_artist], 0.001
        assert_in_delta tracks.to_f / artists.to_f, @stats[:avg_tracks_p_artist], 0.001
        assert_in_delta tracks.to_f / discs.to_f, @stats[:avg_tracks_p_disc], 0.001
        assert_equal albums-albums_waa, @stats[:albums_with_albumart]
      end
      should "graph albums by decade" do
        # NULL, 1972, 1994, 1998, 2002, 2002, 2003
        assert_graph 'albums_by_decade', [
            ['Unknown',     1],
            ['1970 - 1979', 1],
            ['1980 - 1989', 0],
            ['1990 - 1999', 2],
            ['2000 - 2009', 3],
          ]
      end
    end # Context: with no params

    # test with
    #  {:discs => '1'} => %w[ponk in_absentia devdas close_to_the_edge time_and_a_word],
    #  {:va => '0'} => %w[ponk 6doit in_absentia still_life close_to_the_edge time_and_a_word],
    #  {:albumart => '1'} => %w[ponk in_absentia devdas],
    # returns
    #   ponk in_absentia
    context "with filter" do
      setup do
        get :index, :va => '0', :discs => '1', :albumart => '1'
        @stats= assigns(:stats)
      end
      should_respond_with :success
      should_render_template 'index'
      should "calculate the stats correctly" do
        files= tracks= 1+4
        total_filesize= PONK_FILESIZE + IN_ABSENTIA_FILESIZE
        total_length= PONK_LENGTH + IN_ABSENTIA_LENGTH

        assert_equal files, @stats[:files]
        assert_equal total_filesize, @stats[:filesize]
        assert_equal artists=2, @stats[:artists]
        assert_equal albums=2, @stats[:albums]
        assert_equal 0, @stats[:va_albums]
        assert_equal 0, @stats[:multiple_disc_albums]
        assert_equal discs=2, @stats[:discs]
        assert_equal tracks, @stats[:tracks]
        assert_in_delta total_length, @stats[:length], 0.01
        assert_in_delta (247 + 264+260+246+260).to_f / 5.0, @stats[:avg_bitrate], 0.1
        assert_equal albums_waa=0, @stats[:albums_without_albumart]

        assert_in_delta total_length / tracks, @stats[:avg_length], 0.001
        assert_in_delta total_filesize.to_f / files, @stats[:avg_filesize], 0.001
        assert_in_delta albums.to_f / artists.to_f, @stats[:avg_albums_p_artist], 0.001
        assert_in_delta tracks.to_f / artists.to_f, @stats[:avg_tracks_p_artist], 0.001
        assert_in_delta tracks.to_f / discs.to_f, @stats[:avg_tracks_p_disc], 0.001
        assert_equal albums-albums_waa, @stats[:albums_with_albumart]
      end
      should "graph albums by decade" do
        # 1994, 2002
        assert_graph 'albums_by_decade', [
            ['1990 - 1999', 1],
            ['2000 - 2009', 1],
          ]
      end
    end # Context: with va and disc filter

  end # Context: stats/index

  def assert_graph(id, data)
    # Check container and header
    assert_select 'table[id~=?]', id, 1 do
      assert_select 'tr.section', 1

      # Check data rows
      max_value= data.map{|a| a[1]}.max
      assert_select 'tr[class~=?]', /alt[01]/, data.size do |rows|
        assert_equal data.size, rows.size
        rows.each_with_index {|row,i|

          # Check each individual data row
          k,v = data[i]
          assert_select row, 'td.k', k.to_s
          assert_select row, 'td.v2', v.to_s
          assert_select row, 'td.v div', 1 do |div|
            div= div[0]
            style= div.attributes['style']
            assert style =~ /^width:(\d+)%$/
            actual_width= $1.to_i
            if v == 0
              assert_equal 0, actual_width
            elsif v == max_value
              assert_equal 100, actual_width
            else
              expected= (v.to_f * 100.0 / max_value.to_f).round.to_i
              assert_in_delta expected, actual_width, 1
            end
          end

        }
      end
    end
  end
end
