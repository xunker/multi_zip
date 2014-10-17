require 'multi_zip'

require 'pry'
require 'pry-byebug'

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

def stash_constants(lib)
  ZIP_CONSTANTS[lib.to_sym].each do |cc|
    Object.const_set("Stash#{lib}Zip#{cc}".to_sym, Zip.const_get(cc))
    Zip.send(:remove_const, cc)
  end
end

def apply_constants(lib)
  ZIP_CONSTANTS[lib.to_sym].each do |cc|
    Zip.const_set(cc, Object.const_get("Stash#{lib}Zip#{cc}".to_sym))
    Object.send(:remove_const, "Stash#{lib}Zip#{cc}".to_sym)
  end
end

ZIP_CONSTANTS = {}

require 'zip'
ZIP_CONSTANTS[:rubyzip] = Zip.constants
stash_constants(:rubyzip)

require 'zipruby'
ZIP_CONSTANTS[:zipruby] = Zip.constants
stash_constants(:zipruby)
