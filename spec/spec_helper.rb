require 'multi_zip'

# can't use pry on old rubies or on rubinius
if RUBY_VERSION.to_f >= 2.0 && RUBY_ENGINE == 'ruby'
  require 'pry'
  require 'pry-byebug'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = false

  config.order = :random

  # allow you to focus on just one test by adding 'focus: true' to the
  # describe, context or it block.
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  Kernel.srand config.seed
end

def invalid_archive_fixture_filename
  'spec/fixtures/invalid.zip'
end

def archive_fixture_filename
  'spec/fixtures/test.zip'
end

def archive_members
  # assumed to reflect files in spec/fixtures/test/zip
  {
    'file_1.txt' => 38, # member_name => size_in_bytes
    'file_2.txt' => 118,
    'dir_1/' => nil, # directory
    'dir_1/file_3.txt' => 229
  }
end

def archive_member_size(member)
  archive_members[member]
end

def archive_member_names
  archive_members.keys.sort
end

def archive_member_files
  archive_members.reject{|k,v| v.nil? }.keys.sort
end

def archive_member_directories
  # assumed to reflect directories in spec/fixtures/test/zip
  archive_members.select{|k,v| v.nil? }.keys.sort
end

def test_with_rubyzip?
  # rubyzip requires ruby >= 1.9.2
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.2")
    gem 'rubyzip'
    return true
  end
  false
rescue Gem::LoadError
  false  
end

def test_with_zipruby?
  gem 'zipruby'
  true
rescue Gem::LoadError
  false
end

def backends_to_test
  @backends_to_test ||= [
    (test_with_zipruby? ? :zipruby : nil),
    (test_with_rubyzip? ? :rubyzip : nil),
    :archive_zip
  ].compact
end

current_ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'
warn "*** Backends to test under #{current_ruby_engine} #{RUBY_VERSION}: #{backends_to_test.map(&:to_s).join(', ')} ***"
excluded_backends = MultiZip::BACKENDS.keys - backends_to_test
if excluded_backends.length > 0
  warn "*** Backends that will not be tested: #{excluded_backends.map(&:to_s).join(', ')} ***"
end

BACKEND_CONSTANTS = {}
BACKEND_CLASSES = {}

def set_backend_class(lib, klass)
  BACKEND_CONSTANTS[lib.to_sym] = klass.constants
  BACKEND_CLASSES[lib.to_sym] = klass
end

def backend_class(lib)
  BACKEND_CLASSES[lib.to_sym]
end

def stash_constants(lib)
  BACKEND_CONSTANTS[lib.to_sym].each do |cc|
    Object.const_set("Stash#{lib}Zip#{cc}".to_sym, backend_class(lib).const_get(cc))
    backend_class(lib).send(:remove_const, cc)
  end
end

def apply_constants(lib)
  BACKEND_CONSTANTS[lib.to_sym].each do |cc|
    backend_class(lib).const_set(cc, Object.const_get("Stash#{lib}Zip#{cc}".to_sym))
    Object.send(:remove_const, "Stash#{lib}Zip#{cc}".to_sym)
  end
end

if test_with_rubyzip?
  require 'zip'
  set_backend_class(:rubyzip, Zip)
  stash_constants(:rubyzip)
end

if test_with_zipruby?
  require 'zipruby'
  set_backend_class(:zipruby, Zip)
  stash_constants(:zipruby)
end

require 'archive/zip'
# using `Archive` instead of `Archive::Zip`, because we need to stash the
# `::Zip` constant since we use that as the archive/zip fingerprint.
set_backend_class(:archive_zip, Archive)
stash_constants(:archive_zip)
