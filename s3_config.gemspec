# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_config/version'

Gem::Specification.new do |spec|
  spec.name          = "s3_config"
  spec.version       = S3Config::VERSION
  spec.authors       = ["Zane Shannon"]
  spec.email         = ["zcs@smileslaughs.com"]

  spec.summary       = %q{S3Config uses AWS S3 to configure a Rails application.}
  spec.description   = %q{S3Config adopts Heroku-style config management for any Rails application using AWS S3 to store, and Rack middleware to inject environment variables.}
  spec.homepage      = "https://github.com/rails2017/s3_config"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
