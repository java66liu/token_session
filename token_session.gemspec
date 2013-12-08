# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'token_session'

Gem::Specification.new do |spec|
  spec.name          = "token_session"
  spec.version       = TokenSession::VERSION
  spec.authors       = ["Jeff Avallone"]
  spec.email         = ["jeff.avallone@gmail.com"]
  spec.description   = %q{Rack session middleware using a signed token to store the session data. This middleware is targeted at shared-nothing API development.}
  spec.summary       = %q{Token-based Rack session middleware.}
  spec.homepage      = "http://github.com/javallone/token_session"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "metric_fu"

  spec.add_runtime_dependency "rack"
end
