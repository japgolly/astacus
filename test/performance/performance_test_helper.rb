require 'test_helper'

class PerformanceTest < ActiveSupport::TestCase
  self.fixture_path = File.join(File.dirname(__FILE__), "../fixtures.performance" )
  MINIMUM_ROWS= 1000

  def self.test_find_identical(model, reps, time)
    test_name= model.to_s.underscore
    class_eval <<-EOB
      def test_#{test_name}_new
        assert_sufficient_amount_of_data_for #{model}
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
        assert_sufficient_amount_of_data_for #{model}
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

  PROCS= {}
  def self.test_find(model, name, reps, time, &condition_proc)
    test_name= "test_#{model.to_s.underscore}_find_#{name.to_s.underscore.gsub /\s/,'_'}"
    PROCS[test_name]= condition_proc
    class_eval <<-EOB
      def #{test_name}
        assert_sufficient_amount_of_data_for #{model}
        silence #{model} do
          elapsed_time= Benchmark.realtime do
            #{reps}.times {
              #{model}.find :all, :conditions => PROCS['#{test_name}'].call(self)
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
    assert actual_time < max, "Too slow. Actual time was %.2f which is above #{max}." % [actual_time]
  end

  def assert_sufficient_amount_of_data_for(model)
    assert model.count >= MINIMUM_ROWS, "Fixture too small. #{model}.count = #{model.count}."
  end
end
