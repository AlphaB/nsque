require File.expand_path('../lib/nsque/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'nsque'
  gem.version     = Nsque::VERSION
  gem.description = gem.summary = "Background job library based on NSQ (http://nsq.io)"
  gem.authors     = ["Mikhail Salosin"]
  gem.email       = 'mikhail@salosin.me'
  gem.files       = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  gem.homepage    = 'http://rubygems.org/gems/nsque'
  gem.license     = 'MIT'
end
