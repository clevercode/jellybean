guard 'coffeescript', :output => 'build/javascripts' do
  watch(/^vendor/assets/javascripts\/(.*)\.coffee/)
end

guard 'coffeescript', :output => 'spec/javascripts/' do
  watch(/^spec\/coffeescripts\/(.*)\.coffee/)
end

guard 'livereload', :apply_js_live => false do
  watch(/^spec\/javascripts\/.+\.js$/)
  watch(/^build\/javascripts\/.+\.js$/)
end
  
