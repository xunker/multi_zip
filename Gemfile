source 'https://rubygems.org'

gemspec

# can't use pry on old rubies or on rubinius
if RUBY_VERSION.to_f >= 2.2 && RUBY_ENGINE == 'ruby'
  gem 'byebug', :require => false
  gem 'guard-rspec', :require => false
end

# rubyzip requires ruby >= 1.9.2
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.2")
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.0.0")
    # rubyzip 1.2.1 drops support for 1.9.3:
    # https://github.com/rubyzip/rubyzip/pull/256#issuecomment-155860478
    gem 'rubyzip', '1.2.0', :require => nil, :platforms => :ruby
  else
    gem 'rubyzip', '~> 1.2.1', :require => nil, :platforms => :ruby
  end
  gem 'zip-zip', '~>0.3', :require => nil, :platforms => :ruby
end

gem 'zipruby', '0.3.6', :require => nil, :platforms => :ruby
gem 'archive-zip', '~> 0.7.0', :require => nil
