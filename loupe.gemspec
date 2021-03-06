# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loupe/version'

Gem::Specification.new do |spec|
  spec.name          = 'loupe'
  spec.version       = Loupe::VERSION
  spec.authors       = ['Richard Nienaber']
  spec.email         = %w(rjnienaber@gmail.com)
  spec.description   = %q{An easy way to search for security vulnerabilities in your dependencies}
  spec.summary       = %q{Loupe examines your gem dependencies for vulnerabilities and reports on any it finds}
  spec.homepage      = 'https://github.com/rjnienaber/loupe'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/) - %w(.gitignore .rvmrc .travis.yml Gemfile.lock Guardfile)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'slop', '~> 3.4.3'
  spec.add_runtime_dependency 'bundler', '~> 1.3'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec', '~> 2.13.0'
  spec.add_development_dependency 'rake'
end
