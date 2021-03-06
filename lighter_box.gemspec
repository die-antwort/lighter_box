# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lighter_box/version'

Gem::Specification.new do |spec|
  spec.name          = "lighter_box"
  spec.version       = LighterBox::VERSION
  spec.authors       = ["Stefan Daschek"]
  spec.email         = ["stefan@die-antwort.eu"]

  spec.summary       = %q{Lightweight accessible lightbox.}
  spec.homepage      = "https://github.com/die-antwort/lighter_box"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "coffee-script", "~> 2.2"
  spec.add_dependency "sass", "~> 3.2"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
