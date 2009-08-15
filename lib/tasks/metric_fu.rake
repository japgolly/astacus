begin

require 'metric_fu'

MetricFu::Configuration.run do |config|
  config.rcov[:test_files]= ['test/unit/**/*.rb','test/functional/**/*.rb']
  config.rcov[:rcov_opts] << "-Itest"
end

rescue LoadError
end

