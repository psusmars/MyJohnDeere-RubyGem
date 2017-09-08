# MyJohnDeere API Library

The MyJohnDeere Ruby library provides convenient access to the MyJohnDeere API from applications written in the Ruby language. It includes a pre-defined set of classes for API resources that are available currently from the API. You will need to get access by going to the (JohnDeere Developer page)[https://developer.deere.com/#!welcome]. The interface utilizes OAUTH 1.0.

## Development

Run all tests:

    bundle exec rake

Run a single test suite:

    bundle exec ruby -Ilib/ test/myjohndeere_test.rb

Run a single test:

    bundle exec ruby -Ilib/ test/myjohndeere_test.rb -n /some_test/

## Disclaimer

This Gem is in no way associated with The Climate Corporation, and they are in no way associated with it's support, maintenance, or updates.