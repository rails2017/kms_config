# KmsConfig

KmsConfig adopts Heroku-style config management for any Rails application using AWS KMS to encrypt, S3 to store, and Rack middleware to inject environment variables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kms_config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kms_config

## Usage

We're using the same commands as the Heroku CLI. More here: [Heroku Config Vars](https://devcenter.heroku.com/articles/config-vars).

### Setup

`config init`

### List Environment Variables (aka `heroku config`)

`config`

### Write Environment Variable (aka `heroku config:set`)

`config set FOO=BAR`

### Read Environment Variable (aka `heroku config:get`)

`config get FOO`

### Delete Environment Variable (aka `heroku config:unset`)

`config unset FOO`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rails2017/kms_config. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
