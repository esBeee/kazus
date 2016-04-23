# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kazus/constants'

Gem::Specification.new do |spec|
  spec.name          = "kazus"
  spec.version       = Kazus::VERSION
  spec.authors       = ["esBeee"]
  spec.email         = ["sebastianbitzer@posteo.de"]

  spec.summary       = %q{Provides a method that logs a given message along with detailed inspections of all further given objects in a well readable format.}
  spec.description   = %q{Kazus provides a method to log a given message along with detailed inspections of all further given objects in a well readable format. Any logger can be configured for that job. The method is designed to not throw exceptions under any circumstances, to prevent the including app from breaking even if the method wasn't used as arranged.}
  spec.homepage      = "https://github.com/esBeee/kazus"
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

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
