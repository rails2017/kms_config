require "aws-sdk"
require "thor"
require "yaml"

module S3Config
  class CLI < Thor

    no_commands {
      def validate_installed!
        unless S3Config.adapter.new.valid?
          error "Not installed!"
          error "`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_CONFIG_BUCKET` must be defined in your ENV."
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
      @application = S3Config.adapter.new environment: environment
      version = @application.latest_version
      say "#{environment} (v#{version})"
      say "====="
      @application.sort.each do |k,v|
        say "#{k}=#{v}"
      end
    end

    desc "set", "Set S3Config variable for environment. eg: config set production KEY=value"
    def set(environment=nil, *key_values)
      return unless validate_installed!
      return error "Environment required. eg: config set production KEY=value" if environment.nil?
      @application = S3Config.adapter.new environment: environment
      version = @application.latest_version
      key_values.each do |key_value|
        key, value = key_value.split '='
        return error "Key required. eg: config set production KEY=value" if key.nil?
        key.upcase!
        if value.nil?
          error "Value required. eg: config set production KEY=value"
          say "Use `config unset` to delete a key"
          return
        end
        @application.write key, value
        say "Set #{key}=#{value} (#{environment})"
      end
      say "====="
      if @application.latest_version != version
        say "New version: v#{@application.latest_version}"
      end
      say "Use version: v#{@application.latest_version}"
    end

    desc "get", "Get S3Config variable for environment. eg: config get production KEY"
    def get(environment=nil, key=nil)
      return unless validate_installed!
      return error "Environment required. eg: config get production KEY" if environment.nil?
      return error "Key required. eg: config get production KEY" if key.nil?
      key = key.upcase
      @application = S3Config.adapter.new environment: environment
      value = @application.read key
      say "#{key} (#{environment})"
      say "====="
      say value
    end

    desc "unset", "Remove S3Config variable for environment. eg: config unset production KEY"
    def unset(environment=nil, key=nil)
      return unless validate_installed!
      return error "Environment required. eg: config unset production KEY" if environment.nil?
      return error "Key required. eg: config unset production KEY" if key.nil?
      key = key.upcase
      @application = S3Config.adapter.new environment: environment
      version = @application.latest_version
      @application.delete key
      say "Removed #{key} (#{environment})"
      say "====="
      if @application.latest_version != version
        say "New version: v#{@application.latest_version}"
      end
      say "Use version: v#{@application.latest_version}"
    end

    desc "environments", "List S3Config environments. eg: config environments"
    def environments
      return unless validate_installed!
      @application = S3Config.adapter.new
      say "Configured Environments"
      say "====="
      @application.environments.each{ |e| puts "- #{e}" }
    end

  end
end
