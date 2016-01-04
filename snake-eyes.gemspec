# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snake-eyes/version'

Gem::Specification.new do |spec|
  spec.name          = "snake-eyes"
  spec.version       = SnakeEyes::VERSION
  spec.authors       = ["Aleck Greenham"]
  spec.email         = ["greenhama13@gmail.com"]
  spec.summary       = "Automatically convert params in your controllers from camel case to snake case"
  spec.description   = "Automatically convert params in your controllers from camel case to snake case in all or a select few controllers"
  spec.homepage      = "https://github.com/greena13/snake-eyes"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake', '~> 0'
end
