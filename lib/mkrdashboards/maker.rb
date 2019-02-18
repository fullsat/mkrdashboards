require 'yaml'

module Mkrdashboards
  class Maker
    def initialize(filename = "config.yml", basedir = nil)
      @basedir = basedir || Dir.pwd
      @config_filename = filename
    end

    def load_config
      @yaml = YAML.load_file("#{@basedir}/#{@config_filename}")
    end

    def bulk_create(options)
      load_config
      client = Client.new

      old_id = nil
      old_id = client.search_dashboard_id_by_urlpath(@yaml['urlPath']) if options['with-delete']
      client.delete_dashboard(old_id) unless old_id.nil?

      payload = Dashboard.new.build(@yaml)
      client.create_dashboard(payload)
    end
  end
end
