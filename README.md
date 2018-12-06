# avro-patches

This gem contains patches to the official [Apache Avro](https://avro.apache.org/)
Ruby gem v1.8.2.

We have attempted to follow the coding conventions used in the official `avro`
repo.

The following pending or unreleased changes are included:
- [AVRO-1886: Add validation messages](https://github.com/apache/avro/pull/111)
- [AVRO-1695: Ruby support for logical types revisited](https://github.com/apache/avro/pull/116)
- [AVRO-1969: Add schema compatibility checker for Ruby](https://github.com/apache/avro/pull/170)
- [AVRO-2039: Ruby encoding performance improvements](https://github.com/apache/avro/pull/230)
- [AVRO-2200: Option to fail when extra fields are in the payload](https://github.com/apache/avro/pull/321)
- [AVRO-2199: Validate that field defaults have the correct type](https://github.com/apache/avro/pull/320)
- [AVRO-2281: Optimize ruby binary encoder/decoder](https://github.com/apache/avro/pull/401)

In addition, compatibility with Ruby 2.4 (https://github.com/apache/avro/pull/191)
has been integrated with the changes above.

The following Ruby changes are not included, but could be added in the future:
- [AVRO-2001: Adding support for doc attribute](https://github.com/apache/avro/pull/197)
- [AVRO-1873: Add CRC32 checksum to Snappy-compressed blocks](https://github.com/apache/avro/pull/121)

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

