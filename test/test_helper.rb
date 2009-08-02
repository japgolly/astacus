ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

module FixtureAndTestHelpers
  MOCK_DATA_DIR= File.expand_path(File.dirname(__FILE__) + "/mock_data")
  def mock_data_dir
    MOCK_DATA_DIR
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

  FROZEN_CITY_TAGGED= "#{MOCK_DATA_DIR}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
  FROZEN_CITY_NOTAGS= "#{MOCK_DATA_DIR}/frozen city (no tags).mp3"
  BOUM_BOUM_YULA= "#{MOCK_DATA_DIR}/01. Boum Boum Yüla.mp3"
  SEIKIMA_CD1_06= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 1/06 - Burning Blood.mp3"
  SEIKIMA_CD1_13= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 1/13 - Shiroi Kiseki.mp3"
  SEIKIMA_CD2_08= "#{MOCK_DATA_DIR}/聖飢魔II/Compilations/1991 - 愛と虐殺の日々/CD 2/08 - Akai Dama No Densetsu.mp3"
  GOGO7188= "#{MOCK_DATA_DIR}/GO!GO!7188/Albums/2006 - パレード/06 - 雪が降らない街.mp3"
  ALL_MOCK_DATA_FILES= [
    FROZEN_CITY_TAGGED,
    FROZEN_CITY_NOTAGS,
    BOUM_BOUM_YULA,
    SEIKIMA_CD1_06,
    SEIKIMA_CD1_13,
    SEIKIMA_CD2_08,
    GOGO7188,
  ].freeze

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
end

class ActionController::TestCase
  attr_accessor :controller, :request, :response

  def assert_response_matches(regex)
    assert response.body =~ regex, "Response should match #{regex.inspect}"
  end
  def assert_response_doesnt_match(regex)
    assert response.body !~ regex, "Response shouldn't match #{regex.inspect}"
  end
  def assert_response_includes(str)
    assert response.body.include?(str), "Response should include #{str.inspect}"
  end
  def assert_response_doesnt_include(str)
    assert !response.body.include?(str), "Response shouldn't include #{str.inspect}"
  end
end
