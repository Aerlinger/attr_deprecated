# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'attr_deprecated/version'

Gem::Specification.new do |spec|
  spec.name          = "attr_deprecated"
  spec.version       = AttrDeprecated::VERSION
  spec.authors       = ["Anthony Erlinger"]
  spec.email         = ["anthony@handybook.com"]
  spec.summary       = %q{Mark unused model attributes as deprecated.}
  spec.description   = %q{A simple and non-intrusive way to mark deprecated columns/attributes in your models. Any usage of these attributes will logged with a warning message and a trace of where the deprecated attribute was called. An exception can be optionally raised as well.}
  spec.homepage      = "https://github.com/Aerlinger/attr_deprecated"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', ['>= 3.0']

  spec.add_development_dependency 'activerecord', ['>= 3.0']
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "3.1.0"
  spec.add_development_dependency "sqlite3"
end
