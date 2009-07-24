require 'performance/performance_test_helper'

class ModelSpeedTest < PerformanceTest
  fixtures :locations, :audio_content, :audio_files, :images, :audio_tags

  test_find_identical AudioContent, 10, 1.0

  test_find_identical AudioFile, 10, 1.0

  test_find AudioTag, "by audio_file_id", 10, 1.0 do
    @i||=0; {:audio_file_id => @i+=30}
  end

  test_find_identical Image, 10, 1

  # TODO test all models that act as unique
end