# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stackstream/version'

Gem::Specification.new do |spec|
  spec.name = 'stackstream'
  spec.version = Stackstream::VERSION
  spec.authors = ['nictrix']
  spec.email = ['nickwillever@gmail.com']
  spec.summary = 'Build, deploy and manage infrastructure as code'
  spec.homepage = 'https://github.com/stacker-project/stackstream'
  spec.license = "Apache License, Version 2.0"

  spec.cert_chain = ['certs/nictrix.pem']
  spec.signing_key = File.join(Gem.user_home, ".ssh", "gem-private_key.pem") if $0 =~ /gem\z/

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "bin"
  spec.executables = ["stackstream"]
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'docile', '~> 1.1'
  spec.add_runtime_dependency 'fog-aws', '~> 0.11'
  spec.add_runtime_dependency 'gli', '~> 2.14'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'guard-rubocop', '~> 1.2'
  spec.add_development_dependency 'guard-rubycritic', '~> 2.9'
  spec.add_development_dependency 'guard-bundler-audit', '~> 0.1'
  spec.add_development_dependency 'guard-bundler', '~> 2.1'
  spec.add_development_dependency 'simplecov', '~> 0.11'
end
