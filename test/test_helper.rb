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

  def self.should_validate_positive_numericality_of(attr)
    should_validate_numericality_of attr
    should_not_allow_values_for attr, -1, :message => 'must be greater than or equal to 0'
    should_allow_values_for attr, 0, 100.megabytes
  end

  def assert_response_matches(regex)
    assert @response.body =~ regex, "Response should match #{regex.inspect}"
  end
  def assert_response_doesnt_match(regex)
    assert @response.body !~ regex, "Response shouldn't match #{regex.inspect}"
  end
  def assert_response_includes(str)
    assert @response.body.include?(str), "Response should include #{str.inspect}"
  end
  def assert_response_doesnt_include(str)
    assert !@response.body.include?(str), "Response shouldn't include #{str.inspect}"
  end

  def all_models
    @@all_models||= (
      Dir.glob('app/models/**/*.rb').each{|f| require f}
      Object.constants.map{|c| eval c}.select{|c| c.respond_to? :table_name}
    )
  end

  def table_counts
    h= {}
    all_models.each{|t| h[t]= t.count}
    h
  end
end
