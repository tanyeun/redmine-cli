require 'thor'
require 'yaml'

module Redmine
  module Cli
    class NoConfigFileError < StandardError
    end

    class << self

      def config
        begin
          generic_conf '.redmine-rb'
        rescue Errno::ENOENT
          raise NoConfigFileError
          exit 1
        end
      end

      def cache
        begin
          generic_conf '.redmine_cache-rb'
        rescue Errno::ENOENT
          @cache = Thor::CoreExt::HashWithIndifferentAccess.new
        end
      end

      private

      def generic_conf(config_file)
        # Using Ruby Magic(tm) to get the caller's function name to use for
        # setting up instance variables/accessors for generic config files.
        config_name = caller[0][/`.*'/][1..-2]

        if !File.file? config_file
          config_file = File.expand_path "~/#{config_file}"
        end

        contents = YAML.load_file config_file
        if contents
          config ||= Thor::CoreExt::HashWithIndifferentAccess.new(YAML.load_file(config_file))
        else
          config ||= Thor::CoreExt::HashWithIndifferentAccess.new
        end
        self.instance_variable_set("@#{config_name}", config)
      end


    end
  end
end
