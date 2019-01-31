require 'dotenv'
require 'yaml'
require 'json'
require 'faraday'
require 'pp'

Dotenv.load
puts ENV['MACKEREL_APIKEY']

module Mackerel

  class Client
    def create_dashboard(payload)
    end

    def get_hosts_in_role(role_fullname)
      hosts = {
        "hosts" => [
          {
            "id" => "ididididid",
            "status" => "working",
            "memo" => "hogehogenomemo",
            "roles" => {"lab" => "web"}
          }
        ]
      }

      hosts["hosts"].select{|host| host["roles"].map{|s, r| "#{s}:#{r}"}.include?(role_fullname) }
    end
  end

  class BulkDashboardMaker
    def load_config
      @yaml = YAML.load_file("config.tmpl.yml")
    end

    def bulk_create
      load_config
      payload = Dashboard.new.build(@yaml)
      puts payload
      Client.new.create_dashboard(payload)
    end
  end

  class Dashboard
    attr_reader :title
    attr_reader :urlPath
    attr_reader :memo
    attr_reader :widgets

    def build(yaml)
      @title   = yaml["title"]
      @urlPath = yaml["urlPath"]
      @memo    = yaml["memo"]
      @widgets = []
      y = 0
      wgf = WidgetGroupFactory.new

      yaml["widget_params"].each do |param, i|
        group = wgf.create(param["type"])
        group.build(y, param).each do |widget|
          @widgets << widget
        end
        y += group.height
      end

      {
        "title" => self.title,
        "urlPath" => self.urlPath,
        "memo" => self.memo,
        "widgets" => self.widgets
      }.to_json
    end
  end

  class WidgetGroupFactory
    def create(name)
      case name
      when "role" then RoleGroup.new
      when "host" then HostGroup.new
      when "header" then HeaderGroup.new
      end
    end
  end

  class WidgetGroup
    MAX_COLUMN = 24
    attr_reader :row

    def build(y, param); end
    def max_width
      (MAX_COLUMN / ranges.size).to_i
    end

    def height
      6 #All type adopted
    end

    def make_layout(y, i)
      {
        "x" => max_width * i,
        "y" => y,
        "height" => height,
        "width" => 6
      }
    end

    def ranges
      @ranges ||= [
        {},
        {"type" => "relative", "period" => "21600", "offset" => "0"},
        {"type" => "relative", "period" => "259200", "offset" => "0"},
        {"type" => "relative", "period" => "2592000", "offset" => "0"}
      ]
    end
  end

  class HeaderGroup < WidgetGroup
    def build(y, param)
      param['markdowns'].map.with_index do |mkd, i|
        {
          "type" => "markdown",
          "layout" => make_layout(y, i),
          "markdown" => mkd
        }
      end
    end

    def height
      2
    end
  end

  class RoleGroup < WidgetGroup
    def build(y, param)
      ranges.map.with_index do |range, i|
        {
          "type" => "graph",
          "layout" => make_layout(y, i),
          "graph" => param,
          "range" => range,
        }
      end
    end

    def height
      6
    end
  end

  class HostGroup < WidgetGroup
    HEIGHT = 6
    def build(y, param)
      get_host_ids(param['roleFullname']).map.with_index do |id, i|
        ranges.map.with_index do |range, j|
          {
            "type" => "graph",
            "layout" => make_layout(y + HEIGHT * i, j),
            "graph" => {
              "type" => "host",
              "hostId" => id,
              "name" => param["name"]
            },
            "range" => range,
          }
        end
      end.flatten
    end

    def height
      @ids.nil? ? get_host_ids * HEIGHT : @ids.size * HEIGHT
    end

    def get_host_ids(role_fullname)
      hosts = Client.new.get_hosts_in_role(role_fullname)
      @ids = hosts.map{|host| host['id']}
    end
  end
end

Mackerel::BulkDashboardMaker.new.bulk_create
