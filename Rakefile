require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

begin
  require 'closure-compiler'

  desc 'Build compressed Jellybean.js'
  task :build do
    source = File.read('build/javascripts/jellybean.js')
    minified = Closure::Compiler.new.compress(source)
    File.open('build/javascripts/jellybean.min.js', 'w') do |file|
      file.write minified
    end
  end
rescue LoadError
end
