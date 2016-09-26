source 'https://rubygems.org'
ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
gem 'puma'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Ensure keys are not stored publicly on github
gem 'figaro'

# Speed up bulk imports into DB
gem 'activerecord-import'

gem 'bootstrap-sass'

gem 'font-awesome-sass'

# for methods on dates
gem 'activesupport'

gem 'simple_form'

group :development do
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'letter_opener'
  gem 'pry-byebug'
  gem 'pry-rails'
end

group :development, :test do
  gem 'quiet_assets'
  gem 'spring'
  gem 'capybara'
  gem 'poltergeist'
  gem 'phantomjs', :require => 'phantomjs/poltergeist'
  gem 'launchy'
  gem 'minitest-reporters'
  gem 'factory_girl_rails'
end

group :test do
  gem 'database_cleaner'
end

group :production do
  gem 'rails_12factor'
end

