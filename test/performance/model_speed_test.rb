require 'test_helper'

class ModelSpeedTest < ActiveSupport::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures/performance" )
  fixtures :locations, :audio_content, :audio_files, :audio_tags
  MINIMUM_ROWS= 1000

  def self.test_find_identical(model, reps, time)
    test_name= model.to_s.underscore
    class_eval <<-EOB
      def test_#{test_name}_new
        assert #{model}.count >= MINIMUM_ROWS, "Fixture too small. #{model}.count = \#{#{model}.count}."
        m= #{model}.first
        #{model}.delete m.id
        m= m.clone
        silence #{model} do
          elapsed_time= Benchmark.realtime do
            #{reps}.times {
              assert_nil m.find_identical
            }
          end
          assert_time_within #{time}, elapsed_time
        end
      end

      def test_#{test_name}_existing
        m= #{model}.first
        m= m.clone
        silence #{model} do
          elapsed_time= Benchmark.realtime do
            #{reps}.times {
              assert_not_nil m.find_identical
            }
          end
          assert_time_within #{time}, elapsed_time
        end
      end
    EOB
  end

  def silence(base = ActiveRecord::Base)
    base.logger ? base.logger.silence{yield} : yield
  end

  def assert_time_within(max, actual_time)
    assert actual_time < max, "Too slow. Actual time was #{actual_time} which is above #{max}."
  end

  test_find_identical AudioContent, 10, 1.0
  test_find_identical AudioFile, 10, 1.0
  test_find_identical AudioTag, 10, 1.0
end