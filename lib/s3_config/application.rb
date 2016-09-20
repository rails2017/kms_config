require "aws-sdk"
require "erb"
require "yaml"

module S3Config
  class Application

    include Enumerable

    def initialize(options = {})
      @options = options.inject({}) { |m, (k, v)| m[k.to_sym] = v; m }
    end

    def environment
      environment = @options.fetch(:environment) { default_environment }
      environment.nil? ? nil : environment.to_s
    end

    def environment=(environment)
      @options[:environment] = environment
    end

    def configuration
      global_configuration.merge(environment_configuration)
    end

    def load
      each do |key, value|
        skip?(key) ? key_skipped!(key) : set(key, value)
      end
    end

    def each(&block)
      configuration.each(&block)
    end

    # private

    def client
      @s3 ||= Aws::S3::Client.new(access_key_id: ::ENV.fetch("AWS_ACCESS_KEY_ID"), secret_access_key: ::ENV.fetch("AWS_ACCESS_KEY_SECRET"), region: ::ENV.fetch("AWS_REGION", "us-east-1"))
    end

    def bucket
      @bucket ||= Aws::S3::Bucket.new(::ENV.fetch("S3_CONFIG_BUCKET"), client: client)
    end

    def default_version
      @version ||= [(bucket.objects({prefix: "#{environment}/"}).count - 1), 0].max
    end

    def default_environment
      ::ENV["RACK_ENV"]
    end

    def raw_configuration
      if v = ::ENV.fetch("S3_CONFIG_REVISION"){ default_version } and e = environment
        begin
          yaml = bucket.object("#{e}/#{v}.yml").get.body
          config = YAML.load yaml
          return config
        rescue Aws::S3::Errors::NoSuchKey
          if default_environment.nil? or default_environment == 'development'
            warn "No config defined. Ignoring because environment = #{default_environment.to_s}"
          else
            raise ConfigNotDefinedError.new(e, v)
          end
        end
      else
        throw NotImplementedError
      end
      {}
    end

    def global_configuration
      raw_configuration.reject { |_, value| value.is_a?(Hash) }
    end

    def environment_configuration
      raw_configuration[environment] || {}
    end

    def set(key, value)
      non_string_configuration!(key) unless key.is_a?(String)
      non_string_configuration!(value) unless value.is_a?(String) || value.nil?

      ::ENV[key.to_s] = value.nil? ? nil : value.to_s
    end

    def skip?(key)
      ::ENV.key?(key.to_s)
    end

    def non_string_configuration!(value)
      warn "WARNING: Use strings for S3Config configuration. #{value.inspect} was converted to #{value.to_s.inspect}."
    end

    def key_skipped!(key)
      warn "WARNING: Skipping key #{key.inspect}. Already set in ENV."
    end
  end
end
