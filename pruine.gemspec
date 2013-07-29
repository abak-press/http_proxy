# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pruine/version"

Gem::Specification.new do |spec|
  spec.name          = "pruine"
  spec.version       = Pruine::VERSION
  spec.authors       = ["Strech (Sergey Fedorov)"]
  spec.email         = ["strech_ftf@mail.ru"]
  spec.description   = "Cluster balancer for Vines"
  spec.summary       = "Em-proxy based balancer for redis backend of Vines cluster"
  spec.homepage      = "http://github.com/Strech/pruine"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis", "~> 3.0.4"
  spec.add_dependency "http_parser.rb", "~> 0.5.3"
  spec.add_dependency "em-synchrony", "~> 1.0.3"
  spec.add_dependency "em-proxy", "~> 0.1.8"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.0"
  spec.add_development_dependency "mock_redis", "~> 0.8.0"
  spec.add_development_dependency "em-http-request"
  spec.add_development_dependency "simplecov"
end
