namespace :test do
  Rake::TestTask.new(:performance => "db:test:prepare" ) do |t|
    t.libs<< "test"
    t.pattern= 'test/performance/**/*_test.rb'
    t.verbose= true
  end
  Rake::Task['test:performance' ].comment= "Run the performance tests in test/performance"
end