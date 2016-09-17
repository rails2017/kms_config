require "aws-sdk"
require "thor"
require "yaml"

module S3Config
  class CLI < Thor

    no_commands {
      def validate_installed!
        unless @s3 = Aws::S3::Client.new(access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"), secret_access_key: ENV.fetch("AWS_ACCESS_KEY_SECRET"), region: ENV.fetch("AWS_REGION", "us-east-1")) and @bucket = Aws::S3::Bucket.new(ENV.fetch("S3_CONFIG_BUCKET"), client: @s3)
          error "Not installed!"
          error "`AWS_ACCESS_KEY_ID`, `AWS_ACCESS_KEY_SECRET`, and `S3_CONFIG_BUCKET` must be defined in your ENV."
          false
        else
          true
        end
      end
    }

    desc "list", "List S3Config variables for environment. eg: config list production"
    def list(environment=nil)
      return unless validate_installed!
      return error "Environment required. eg: config list production" if environment.nil?
      if version = (@bucket.objects({prefix: "#{environment}/"}).count - 1) and version > 0
        yaml = @bucket.object("#{environment}/#{version}.yml").get.body
        say "v#{version}"
        say "====="
        config = YAML.load yaml
        config.each do |k,v|
          say "#{k}=#{v}"
        end
      else
        error "Environment not configured"
        say "Set a variable. eg: config set #{environment} KEY=value"
      end
    end

    desc "set", "Set S3Config variable for environment. eg: config set production KEY=value"
    def set(environment=nil, key_value="")
      return unless validate_installed!
      return error "Environment required. eg: config set production KEY=value" if environment.nil?
      key, value = key_value.split '='
      return error "Key required. eg: config set production KEY=value" if key.nil?
      key.upcase!
      if value.nil?
        error "Value required. eg: config set production KEY=value"
        say "Use `config unset` to delete a key"
        return
      end
      next_version = 1
      config = {}
      if next_version = @bucket.objects({prefix: "#{environment}/"}).count and next_version > 0
        yaml = @bucket.object("#{environment}/#{next_version - 1}.yml").get.body
        config = YAML.load yaml
        version = next_version
      end
      if config[key] == value
        say "No changes."
        say "Use v#{next_version - 1}"
        return
      end
      config[key] = value
      @bucket.put_object({
        body: YAML.dump(config),
        key: "#{environment}/#{next_version}.yml",
        server_side_encryption: "AES256"
      })
      say "New version: v#{next_version}"
    end

    desc "get", "Get S3Config variable for environment. eg: config get production KEY"
    def get(environment=nil, key=nil)
      return unless validate_installed!
      return error "Environment required. eg: config get production KEY" if environment.nil?
      return error "Key required. eg: config get production KEY" if key.nil?
      key = key.upcase
      if version = (@bucket.objects({prefix: "#{environment}/"}).count - 1) and version > 0
        yaml = @bucket.object("#{environment}/#{version}.yml").get.body
        config = YAML.load yaml
        say config[key]
      else
        error "Environment not configured"
        say "Set a variable. eg: config set #{environment} KEY=value"
      end
    end

    desc "unset", "Remove S3Config variable for environment. eg: config unset production KEY"
    def unset(environment=nil, key=nil)
      return unless validate_installed!
      return error "Environment required. eg: config unset production KEY" if environment.nil?
      return error "Key required. eg: config unset production KEY" if key.nil?
      key = key.upcase
      next_version = 1
      config = {}
      if next_version = @bucket.objects({prefix: "#{environment}/"}).count and next_version > 0
        yaml = @bucket.object("#{environment}/#{next_version - 1}.yml").get.body
        config = YAML.load yaml
        version = next_version
      end
      if config[key].nil?
        say "No changes."
        say "Use v#{next_version - 1}"
        return
      end
      config.delete key
      @bucket.put_object({
        body: YAML.dump(config),
        key: "#{environment}/#{next_version}.yml",
        server_side_encryption: "AES256"
      })
      say "New version: v#{next_version}"
    end

    desc "environments", "List S3Config environments. eg: config environments"
    def environments
      return unless validate_installed!
      if @bucket.objects.count > 0
        @bucket.objects.map(&:key).map{|key| key.split('/').first }.uniq.each do |object|
          puts object
        end
      else
        error "No environments configured"
        say "Set a variable. eg: config set ENVIRONMENT KEY=value"
      end
    end

  end
end
