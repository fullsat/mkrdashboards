module Mkrdashboards
  class Command < Thor
    desc 'create', 'make a mackerel dashboard'
    option :file, aliases: 'f', default: 'config.yml'
    option :key , aliases: 'k'
    option :"with-delete", default: 'false', type: 'boolean'
    def create
      ENV['MACKEREL_APIKEY'] = options[:key] unless options[:key].nil?
      Maker.new(options[:file]).bulk_create(options)
    end
  end
end
