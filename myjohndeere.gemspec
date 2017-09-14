$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'myjohndeere/version'

spec = Gem::Specification.new do |s|
  s.name = 'myjohndeere'
  s.version = MyJohnDeere::VERSION
  s.required_ruby_version = '>= 1.9.3'
  s.summary = 'Ruby bindings for the MyJohnDeere API'
  s.description = ' MyJohnDeere is used to make data-driven decisions to maximize your return on every acre. This Ruby Gem is provided as a convenient way to access their API.'
  s.author = 'Paul Susmarski'
  s.email = 'paul@susmarski.com'
  s.homepage = 'https://github.com/psusmars/myjohndeere'
  s.license = 'MIT'

  s.add_dependency "oauth", ">= 0.5.3"

  s.files = Dir['lib/**/*.rb']
  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end