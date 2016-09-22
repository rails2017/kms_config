# S3Config

S3Config adopts Heroku-style config management for any Rails application using AWS S3 to store, and Rack middleware to inject environment variables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3_config

## Setup

`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_CONFIG_BUCKET` must be defined in your ENV.

## Usage

### In Rails

S3Config adds a railtie callback `before_configuration` that pulls stored configuration variables from S3 just before the Rails application is configured (eg. `config/application.rb` executes).

We're using the same commands as the Heroku CLI. More here: [Heroku Config Vars](https://devcenter.heroku.com/articles/config-vars).

### List Environments

`config environments`

### List Environment Variables (aka `heroku config`)

`config list ENVIRONMENT`

### Write Environment Variable (aka `heroku config:set`)

`config set ENVIRONMENT FOO=BAR`

### Read Environment Variable (aka `heroku config:get`)

`config get ENVIRONMENT FOO`

### Delete Environment Variable (aka `heroku config:unset`)

`config unset ENVIRONMENT FOO`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rails2017/s3_config. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
