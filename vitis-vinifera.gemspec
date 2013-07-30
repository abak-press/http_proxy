# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vitis/version"

Gem::Specification.new do |spec|
  spec.name          = "vitis-vinifera"
  spec.version       = Vitis::VERSION
  spec.authors       = ["Strech (Sergey Fedorov)"]
  spec.email         = ["strech_ftf@mail.ru"]
  spec.description   = "Em-proxy based dsl for writting http requests processing"
  spec.summary       = "Proxy server for processing http requests"
  spec.homepage      = "http://github.com/abak-press/vitis-vinifera"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "http_parser.rb", "~> 0.5.3"
  spec.add_dependency "em-synchrony", "~> 1.0.3"
  spec.add_dependency "em-proxy", "~> 0.1.8"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.0"
  spec.add_development_dependency "simplecov"
end
