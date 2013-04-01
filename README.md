loupe
=====

Loupe examines your gem dependencies for vulnerabilities and reports on any it finds

## Installation

Add this line to your application's Gemfile:

    gem 'loupe'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install loupe

## Basic usage

To examine the Gemfile in the current directory is:

    $ loupe

To examine a Gemfile.lock do the following:

    $ loupe -l Gemfile.lock

To examine multiple files at once:

    $ loupe -g app1/Gemfile,app2/Gemfile -l app2/Gemfile.lock,app3/Gemfile.lock

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
