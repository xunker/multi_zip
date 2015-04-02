require 'multi_zip'

if RUBY_VERSION.to_f >= 2.0
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

  Kernel.srand config.seed
end

def fixture_zip_file
  'spec/fixtures/mymedia_lite-20130621.epub'
end

def test_with_rubyzip?
  # rubyzip requires ruby >= 1.9.2
  Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("1.9.2")
end

def backends_to_test
  [
    :zipruby,
    (test_with_rubyzip? ? :rubyzip : nil),
    :archive_zip
  ].compact
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

require 'zipruby'
set_backend_class(:zipruby, Zip)
stash_constants(:zipruby)

require 'archive/zip'
# using `Archive` instead of `Archive::Zip`, because we need to stash the
# `::Zip` constant since we use that as the archive/zip fingerprint.
set_backend_class(:archive_zip, Archive)
stash_constants(:archive_zip)
