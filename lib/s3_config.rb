require "s3_config/version"
require "s3_config/error"
require "s3_config/env"
require "s3_config/application"

module S3Config
  extend self

  attr_writer :adapter, :application

  def env
    S3Config::ENV
  end

  def adapter
    @adapter ||= S3Config::Application
  end

  def application
    @application ||= adapter.new
  end

  def load
    application.load
  end

  def require_keys(*keys)
    missing_keys = keys.flatten - ::ENV.keys
    raise MissingKeys.new(missing_keys) if missing_keys.any?
  end
end

require "s3_config/rails"
