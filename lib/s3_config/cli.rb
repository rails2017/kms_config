require "thor"

module S3Config
  class CLI < Thor
    # config install

    desc "install", "Install S3Config"

    def install
      require "s3_config/cli/install"
      Install.start
    end

  end
end
