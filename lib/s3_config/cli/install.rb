require "thor/group"

module S3Config
  class CLI < Thor
    class Install < Thor::Group
      include Thor::Actions

      
    end
  end
end
