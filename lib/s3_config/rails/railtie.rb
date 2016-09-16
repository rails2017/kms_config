module S3Config
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        S3Config.load
      end
    end
  end
end
