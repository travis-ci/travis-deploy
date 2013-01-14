# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = 'travis-deploy'
  gem.version = '0.0.10'

  gem.authors     = ['Travis Deploy Tool']
  gem.email       = ['contact@travis-ci.org']
  gem.description = 'A command-line interface to Travis CI'
  gem.summary     = gem.description
  gem.homepage    = 'https://github.com/travis-ci/travis-cli'

  gem.add_dependency 'thor', '~> 0.16.0'
  gem.add_dependency 'multi_json', '~> 1.3'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'webmock', '~> 1.8'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(/^bin/).map{|f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ['lib']
end
