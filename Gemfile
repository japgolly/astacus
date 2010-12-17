source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'sqlite3-ruby', :require => 'sqlite3'

group :test do
  gem 'autotest'
  gem 'autotest-rails-pure'
  gem 'test_notifier'
  gem 'redgreen'
  gem 'test-unit', '1.2.3'
  gem 'win32console' if (RUBY_PLATFORM rescue PLATFORM) =~ /win32/
  #gem 'ci_reporter'
  gem 'ci_reporter', :require => 'ci/reporter/test_unit'
end

gem 'backgroundrb-rails3', :require => 'backgroundrb'
gem 'mysql' # requires libmysqlclient-dev
gem 'apetag'
gem 'ruby-mp3info', :require => 'mp3info'
gem 'thoughtbot-shoulda', :require => 'shoulda'
gem 'packet' # for BackgrounDRb
gem 'chronic' # for BackgrounDRb
#gem 'mislav-will_paginate', '~> 2.3.8', :require => 'will_paginate'
gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => "rails3"


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
