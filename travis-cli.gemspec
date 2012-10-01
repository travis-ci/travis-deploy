# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'travis_cli/version'

Gem::Specification.new do |s|
  s.name         = "travis"
  s.version      = TravisCli::VERSION
  s.authors      = ["Travis CI"]
  s.email        = "contact@travis-ci.org"
  s.homepage     = "https://github.com/travis-ci/travis-cli"
  s.summary      = "[summary]"
  s.description  = "[description]"

  s.files        = Dir['{lib/**/*,spec/**/*,[A-Z]*}']
  s.executables  = Dir['bin/*'].map { |path| File.basename(path) }
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency 'thor'
  s.add_dependency 'multi_json'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'fakeweb'
end
