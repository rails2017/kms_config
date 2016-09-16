begin
  require "rails"
rescue LoadError
else
  require "s3_config/rails/application"
  require "s3_config/rails/railtie"

  S3Config.adapter = Figaro::Rails::Application
end
