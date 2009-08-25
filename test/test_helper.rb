ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

module FixtureAndTestHelpers
  MOCK_DATA_DIR= File.expand_path(File.dirname(__FILE__) + "/mock_data")
  def mock_data_dir(suffix=nil)
    suffix ? File.join(MOCK_DATA_DIR,suffix) : MOCK_DATA_DIR
  end
end

module FixtureHelpers
  include FixtureAndTestHelpers
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  include FixtureAndTestHelpers
  include RailsReflection
  setup :log_test_name

  USER_ID_SESSION_KEY= :user_id

  FROZEN_CITY_TAGGED= "#{MOCK_DATA_DIR}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
  FROZEN_CITY_NOTAGS= "#{MOCK_DATA_DIR}/frozen city (no tags).mp3"
  BOUM_BOUM_YULA= "#{MOCK_DATA_DIR}/01. Boum Boum Yüla.mp3"
  SEIKIMA_CD1_06= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 1/06 - Burning Blood.mp3"
  SEIKIMA_CD1_13= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 1/13 - Shiroi Kiseki.mp3"
  SEIKIMA_CD2_08= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 2/08 - Akai Dama No Densetsu.mp3"
  GOGO7188= "#{MOCK_DATA_DIR}/GO!GO!7188/Albums/2006 - パレード/06 - 雪が降らない街.mp3"
  DEVDAS_1= "#{MOCK_DATA_DIR}/Devdas/01 - Silsila ye Chaahat ka.mp3"
  DEVDAS_2= "#{MOCK_DATA_DIR}/Devdas/02 - Maar Daala.mp3"
  TAGCHANGE_ALBUMART_BEFORE= "#{MOCK_DATA_DIR}/tag_changes/albumart-before.mp3"
  TAGCHANGE_ALBUMART_AFTER= "#{MOCK_DATA_DIR}/tag_changes/albumart-after.mp3"
  TAGCHANGE_TRACK_BEFORE= "#{MOCK_DATA_DIR}/tag_changes/track-before.mp3"
  TAGCHANGE_TRACK_AFTER= "#{MOCK_DATA_DIR}/tag_changes/track-after.mp3"
  DJANGO= "#{MOCK_DATA_DIR}/Rhythm_Futur.mp3"
  PROCEED_WITH_CAUTION= "#{MOCK_DATA_DIR}/Proceed With Caution.mp3"

  ALL_MOCK_DATA_FILES= [
    FROZEN_CITY_TAGGED,
    FROZEN_CITY_NOTAGS,
    BOUM_BOUM_YULA,
    SEIKIMA_CD1_06, SEIKIMA_CD1_13, SEIKIMA_CD2_08,
    GOGO7188,
    DEVDAS_1, DEVDAS_2,
    TAGCHANGE_ALBUMART_BEFORE, TAGCHANGE_ALBUMART_AFTER,
    TAGCHANGE_TRACK_BEFORE, TAGCHANGE_TRACK_AFTER,
    DJANGO,
    PROCEED_WITH_CAUTION,
  ].freeze

  # Make sure all ALL_MOCK_DATA_FILES exist
  ALL_MOCK_DATA_FILES.each {|f|
    raise "#{f} doesn't exist." unless File.exists?(f)
  }

  def self.should_validate_positive_numericality_of(attr)
    should_validate_numericality_of attr
    should_not_allow_values_for attr, -1, :message => 'must be greater than or equal to 0'
    should_allow_values_for attr, 0, 100.megabytes
  end

  def table_counts
    h= {}
    all_models.each{|t| h[t.to_s]= t.count}
    h
  end

  def count_audio_tags_tracks
    ActiveRecord::Base.connection.select_value('select count(*) from audio_tags_tracks').to_i
  end

  def assert_same_named_elements(expected, actual)
    assert_same_elements expected.map(&:name), actual.map(&:name)
    assert_same_elements expected, actual
  end

  private
    # This prints the test name to the log before each test.
    def log_test_name
      return unless l= Rails::logger and !@already_logged_this_test
      @already_logged_this_test= true
      name= "#{self.class}: #{@method_name.sub /^test: /, ''}"
      l.info "\n\n\e[32;1m#{name}\e[0m\n\e[32;1m#{'-' * name.length}\e[0m\n"
    end
end

class ActionController::TestCase
  attr_accessor :controller, :request, :response

  def assert_response_matches(regex)
    assert response.body =~ regex, "Response should match #{regex.inspect}"
  end
  def assert_response_doesnt_match(regex)
    assert response.body !~ regex, "Response shouldn't match #{regex.inspect}"
  end

  # Checks that a certain string exists in the response.
  def assert_response_includes(str, expected= true)
    if expected
      assert response.body.include?(str), "Response should include #{str.inspect}"
    else
      assert_response_doesnt_include str
    end
  end
  def assert_response_doesnt_include(str)
    assert !response.body.include?(str), "Response shouldn't include #{str.inspect}"
  end

  def ajax_get(*args)
    xml_http_request :get, *args
  end
  def ajax_post(*args)
    xml_http_request :post, *args
  end

  def cur_user_id
    session[USER_ID_SESSION_KEY]
  end
  def cur_user
    User.find(cur_user_id) if cur_user_id
  end
  def login(id_or_model=nil)
    if id_or_model == false
      session[USER_ID_SESSION_KEY]= nil
    else
      id_or_model||= User.first
      id= id_or_model.is_a?(User) ? id_or_model.id : id_or_model
      session[USER_ID_SESSION_KEY]= id
    end
  end
end
