source 'https://rubygems.org'

ruby "2.1.1"
gem "bootstrap-sass"
gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'
gem 'bootstrap_form'
gem 'font-awesome-sass'
gem 'chartkick', '~> 1.2.4'
gem 'groupdate', '~> 2.1.0'
gem 'bootstrap_tokenfield_rails'

gem 'jquery-turbolinks'
gem 'devise'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'feedjira'
gem 'gon'
gem 'pry'
gem 'pry-byebug'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem "koala", "~> 1.8.0rc1"

group :production do
# pre-req for Heroku integration, RoR 4+
  gem "rails_12factor"
end

group :development, :test do
# Read env settings from .env file like heroku does
  gem "foreman"
  gem "pry-rails"
end

#### Default

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.4'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

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
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
