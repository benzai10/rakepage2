source 'https://rubygems.org'

ruby "2.1.1"
gem 'sass-rails', '~> 4.0.2'
gem "bootstrap-sass"
gem 'bootstrap_form'
gem 'font-awesome-rails'
gem 'chartkick', '~> 1.2.4'
gem 'groupdate', '~> 2.1.0'
gem 'bootstrap_tokenfield_rails'
gem 'social-share-button'
gem 'mechanize', '2.7.2'
gem 'rails4-autocomplete', '~> 1.1.1'
gem 'friendly_id', '~> 5.0.0'
gem 'metamagic'
gem 'newrelic_rpm'
# gem 'elasticsearch-rails', '~> 0.1.5'
# gem "searchkick"
# gem 'jquery-turbolinks'

# authentication gem
gem 'devise'
# admin page 
gem 'activeadmin', github: 'gregbell/active_admin'

# use 3 parties to authenticate
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

# gems to handle rss/fb/twitter
gem 'feedjira'
gem "koala", "~> 1.8.0rc1"
gem "twitter"

# needs to load env files for precompile to function
gem 'dotenv'

# gzips assets for faster webpage
gem 'rack-zippy'

group :production do
# pre-req for Heroku integration, RoR 4+
  gem "rails_12factor"
end

group :development, :test do
# Read env settings from .env file like heroku does
  gem "foreman"
# Pry instead of IRB as repl
  gem 'pry'
# rails c invokes pry
  gem "pry-rails"
# Debug with pry
  gem 'pry-byebug'
# Rescue server with pry
  gem 'pry-rescue'
# Test suite minitest-rails
  gem 'minitest-rails', '~> 1.0'
  gem 'minitest-rails-capybara'
  gem 'minitest-colorize'
  gem 'minitest-focus'
  gem 'fabrication'
  gem 'faker'
# Traceroute
  gem 'traceroute'
# Bullet
  gem 'bullet'
# Rack Mini Profiler
  gem 'rack-mini-profiler'
end

#### Default

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.4'

# Use postgresql as the database for Active Record
gem 'pg'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-cookie-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'
gem 'rabl'

# Provides Holder.js to render image placeholders entirely on the client side
gem 'holder_rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
