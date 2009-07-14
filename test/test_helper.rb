ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

  MOCK_DATA_DIR= File.expand_path(File.dirname(__FILE__) + "/mock_data")
  def mock_data_dir
    MOCK_DATA_DIR
  end

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
end
