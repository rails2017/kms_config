module S3Config
  module Rails
    class Application < S3Config::Application
      private

      def default_environment
        ::Rails.env
      end

      def rails_not_initialized!
        raise RailsNotInitialized
      end
    end
  end
end
