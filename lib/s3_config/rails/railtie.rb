module S3Config
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        begin
          S3Config.load
        rescue S3Config::ConfigNotDefinedError => e
          if ::Rails.env.development?
            warn "S3Config not defined. Ignoring for development environment."
          else
            raise e
          end
        end
      end
    end
  end
end
