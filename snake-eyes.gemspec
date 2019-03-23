# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'snake-eyes/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'snake-eyes'
  s.version       = SnakeEyes::VERSION
  s.authors       = ['Aleck Greenham']
  s.email         = ['greenhama13@gmail.com']
  s.summary       = 'Automatically convert params in your controllers from camel case to snake case'
  s.description   = 'Automatically convert params in your controllers from camel case to snake case in all or a select few controllers'
  s.homepage      = 'https://github.com/greena13/snake-eyes'
  s.license       = 'MIT'

  s.files = Dir['lib/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.require_paths = ['lib']
  s.test_files    = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 4.2.5'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
end
