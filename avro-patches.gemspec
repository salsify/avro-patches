# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'avro-patches/version'

Gem::Specification.new do |spec|
  spec.name          = 'avro-patches'
  spec.version       = AvroPatches::VERSION
  spec.authors       = ['Salsify, Inc']
  spec.email         = ['engineering@salsify.com']

  spec.summary       = 'Patches for the official Apache Avro Ruby implementation'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/salsify/avro-patches'

  spec.license       = 'MIT'

  # Set 'allowed_push_post' to control where this gem can be published.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin|test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'overcommit'

  spec.add_runtime_dependency 'avro', '>= 1.9.0', '<= 1.9.1'
end
