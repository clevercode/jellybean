require 'compass'
require 'barista'

module Jellybean

  def self.root
    File.expand_path('..', File.dirname(__FILE__))
  end

  def self.install_barista_framework!
    Barista::Framework.register("jellybean", "#{root}/coffeescripts/")
  end

  def self.install_compass_framework!
    Compass::Frameworks.register('jellybean', :path => root)
  end

  self.install_barista_framework! 
  self.install_compass_framework! 

end
