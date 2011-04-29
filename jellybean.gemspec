version = '0.0.1'

Gem::Specification.new do |s|
  s.name = 'jellybean'
  s.version = version
  s.platform = Gem::Platform::RUBY
  s.authors = ['Andrew Smith']
  s.email = ['andrew@clevercode.net']
  s.homepage = 'http://github.com/clevercode/sweetsute-gem'
  s.summary = %q{ The SweetSuite UI framework }
  s.description = %q{ The Sweet Suite UI framework that incorporates a sass stylesheets, coffeescripts, and common helpers and templates }
  s.files = `git ls-files`.split("\n")
  s.test_files = []
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = []
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'barista'
  s.add_runtime_dependency 'compass', '~> 0.11.0'
end
