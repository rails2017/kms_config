require "aws-sdk"
require "erb"
require "yaml"

module S3Config
  class Application

    include Enumerable

    def initialize(options = {})
      @options = options.inject({}) { |m, (k, v)| m[k.to_sym] = v; m }
    end

    def environments
      bucket.objects.map(&:key).map{|key| key.split('/').first }.uniq
    end

    def environment
      environment = @options.fetch(:environment) { default_environment }
      environment.nil? ? nil : environment.to_s
    end

    def environment=(environment)
      @options[:environment] = environment
    end

    def version
      version = @options.fetch(:version) { default_version }
      version
    end

    def version=(version)
      @options[:version] = version
    end

    def configuration
      @configuration ||= read_configuration
    end

    def load
      each do |key, value|
        skip?(key) ? key_skipped!(key) : graduate_to_env(key, value)
      end
    end

    def each(&block)
      configuration.each(&block)
    end

    def valid?
      !client.nil? and !bucket.nil?
    end

    def versions_count
      bucket.objects({prefix: "#{environment}/"}).count
    end

    def latest_version
      [versions_count - 1, 0].max
    end

    def read(key)
      config = read_configuration
      config[key]
    end

    def write(key, value)
      begin
        config = read_configuration
      rescue ConfigNotDefinedError
        config = {}
      end
      unless config[key] == value
        config[key] = value
        write_configuration config
      end
    end

    def delete(key)
      config = read_configuration
      unless config[key].nil?
        config.delete key
        write_configuration config
      end
    end

    private

    def client
      @s3 ||= Aws::S3::Client.new(access_key_id: ::ENV.fetch("AWS_ACCESS_KEY_ID"), secret_access_key: ::ENV.fetch("AWS_ACCESS_KEY_SECRET"), region: ::ENV.fetch("AWS_REGION", "us-east-1"))
    end

    def bucket
      @bucket ||= Aws::S3::Bucket.new(::ENV.fetch("S3_CONFIG_BUCKET"), client: client)
    end

    def default_environment
      nil
    end

    def default_version
      @default_version ||= ::ENV.fetch("S3_CONFIG_REVISION"){ latest_version }
    end

    def read_configuration
      if e = environment and v = version
        begin
          serialized_config = bucket.object("#{e}/#{v}.yml").get.body
          config = YAML.load serialized_config
          return config
        rescue Aws::S3::Errors::NoSuchKey
          raise ConfigNotDefinedError.new(e, v)
        end
      else
        throw NotImplementedError
      end
      {}
    end

    def write_configuration(config)
      if e = environment and next_version = versions_count
        serialized_config = YAML.dump(config)
        bucket.put_object({
          body: serialized_config,
          key: "#{e}/#{next_version}.yml",
          server_side_encryption: "AES256"
        })
      else
        throw NotImplementedError
      end
    end

    def graduate_to_env(key, value)
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
