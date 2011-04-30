Jellybean
=========

Its the UI framework of the future!


## Installation

1. **Add to the Gemfile**
   
        gem 'jellybean', :git => 'git@github.com/clevercode/jellybean.git'

2. **Add to your Compass config**

        # in config/compass.rb
        require 'jellybean'

3. **Use it!**

        # in your layout file

        javascript_include_tag 'underscore', 'jellybean', 'application'

        # in your sass stylesheet:

        @import jellybean



## Tests

The test suite uses the Jasmine framework. 

To run the tests:

    # At your terminal
    bundle exec gaurd

    # In another terminal
    bundle exec rake jasmine

    The test suite runs at http://localhost:8888

   
   
