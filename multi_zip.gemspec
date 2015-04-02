# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_zip/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_zip"
  spec.version       = MultiZip::VERSION
  spec.authors       = ["Matthew Nielsen"]
  spec.email         = ["xunker@pyxidis.org"]
  spec.summary       = %q{Abstracts zipping and unzipping using whatever gems are installed, automatically.}
  spec.description   = %q{Abstracts zipping and unzipping using whatever gems are installed using one consistent API. Provides swappable zipping/unzipping backends so you're not tied to just one gem. Support rubyzip, archive-zip, zipruby and others.}
  spec.homepage      = "https://github.com/xunker/multi_zip"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6.2"
  spec.add_development_dependency "rake", "~> 10.3.2"
  spec.add_development_dependency "rspec", "~> 3.1.0"
end
