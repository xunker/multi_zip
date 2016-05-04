source 'https://rubygems.org'

gemspec

# can't use pry on old rubies or on rubinius
if RUBY_VERSION.to_f >= 2.2 && RUBY_ENGINE == 'ruby'
  gem 'byebug', :require => false
  gem 'guard-rspec', :require => false
end

# rubyzip requires ruby >= 1.9.2
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.2")
  gem 'rubyzip', '~> 1.1.6', :require => nil, :platforms => :ruby
  gem 'zip-zip', '~>0.3', :require => nil, :platforms => :ruby
end

gem 'zipruby', '0.3.6', :require => nil, :platforms => :ruby
gem 'archive-zip', '~> 0.7.0', :require => nil
