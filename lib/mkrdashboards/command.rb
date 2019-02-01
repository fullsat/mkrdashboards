module Mkrdashboards
  class Command < Thor
    desc 'create', 'make a mackerel dashboard'
    def create
      Maker.new.bulk_create
      puts "[Done]"
    end
  end
end
