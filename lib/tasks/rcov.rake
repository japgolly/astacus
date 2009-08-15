begin

require 'rcov/rcovtask'

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/unit/**/*.rb'] + FileList['test/functional/**/*.rb']
  t.rcov_opts = ['--rails', '-x /var/lib/,/usr/lib/']
  t.rcov_opts << '--text-report'
  t.rcov_opts << '--sort coverage'
  t.output_dir = 'doc/coverage'
  t.libs << "test"
  t.verbose = true
end

rescue LoadError
end
