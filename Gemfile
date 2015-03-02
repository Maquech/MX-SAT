source 'https://rubygems.org'

gemspec

group :development do
  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false
  gem "pry"
  gem "pry-remote"
  gem "pry-byebug", platform: [:mri_20, :mri_21, :mri_22]
  gem 'terminal-notifier'
  gem 'terminal-notifier-guard'
end

group :development, :test do
  gem "bundler"
  gem "rake"
  gem "rspec", "~> 3.2"
end

group :test do
  gem "coveralls", require: false
  gem "codeclimate-test-reporter"
  gem 'rspec-collection_matchers'
  gem 'equivalent-xml'
  gem 'shoulda-matchers', require: false
end

group :doc do
  gem 'yard'
  gem 'redcarpet'
  gem 'github-markup'
end
