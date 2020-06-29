# avro-patches

## Avro v1.10.0

This gem is compatible with Avro v1.10.0 and does not contain any patches for
that version.

## Avro v1.9.x

After the official release of [Apache Avro](https://avro.apache.org/) v1.9.0 this
gem non longer contains any patches. This version is being released as a compatibility
layer for Avro v1.9.0.

As Ruby changes are submitted for the next Avro release, it is expected that they
be collected in future releases of this gem.

## Avro v1.8.2

See the [avro-v1.8.2 branch](https://github.com/salsify/avro-patches/tree/avro-1.8.2)
for details about the previous version of this gem which supported Avro v1.8.2. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'avro-patches'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install avro-patches

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/salsify/avro-patches.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

