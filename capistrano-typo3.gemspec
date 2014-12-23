# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/typo3/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-typo3"
  spec.version       = Capistrano::Typo3::VERSION
  spec.authors       = ["Pim Snel"]
  spec.email         = ["pim@lingewoud.nl"]
  spec.summary       = %q{Capistrano 3 tasks for TYPO3 CMS}
  spec.description   = %q{Capistrano 3 tasks for TYPO3 CMS. Incl. TYPO3 versions 4.5.x ... 6.2.x.}
  spec.homepage      = "https://github.com/mipmip/capistrano-typo3"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "capistrano", ">= 3.1.0"
end
