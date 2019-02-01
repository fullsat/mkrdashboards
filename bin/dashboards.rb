require 'dotenv'
require 'yaml'
require 'json'
require 'faraday'

Dotenv.load

module Mackerel
  class ObjectCache
    @@hash_objects = {}
    def self.write(key, object)
      @@hash_objects[key] = object
    end

    def self.read(key)
      @@hash_objects[key]
    end
  end

  class Client
    ENDPOINT = "https://api.mackerelio.com/"

    def create_dashboard(payload)
      res = connection.post do |req|
        req.url '/api/v0/dashboards'
        req.headers['X-Api-Key'] = ENV['MACKEREL_APIKEY']
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
      res.body
    end

    def delete_dashboard(dashboard_id)
      res = connection.delete do |req|
        req.url "/api/v0/dashboards/#{dashboard_id}"
        req.headers['X-Api-Key'] = ENV['MACKEREL_APIKEY']
        req.headers['Content-Type'] = 'application/json'
      end
      res.body
    end

    def search_dashboard_id_by_urlpath(url_path)
      dashboards = ObjectCache::read('dashboards')
      if dashboards.nil?
        res = connection.get do |req|
          req.url '/api/v0/dashboards'
          req.headers['X-Api-Key'] = ENV['MACKEREL_APIKEY']
          req.headers['Content-Type'] = 'application/json'
        end
        dashboards = JSON.parse(res.body)
        ObjectCache::write('dashboards', dashboards)
      end

      ids = dashboards["dashboards"].select{|d| d["urlPath"] == url_path }.map{|d| d["id"]}
      ids.first
    end

    def list_hosts_with_role(role_fullname)
      res = connection.get do |req|
          req.url '/api/v0/hosts'
          req.headers['X-Api-Key'] = ENV['MACKEREL_APIKEY']
          req.headers['Content-Type'] = 'application/json'
          req.params['status'] = ["working", "standby", "maintenance", "poweroff"]
      end
      hosts = JSON.parse(res.body)
      hosts["hosts"].select! do |host|
        host["roles"].map do |s, roles|
          roles.map{|r| "#{s}:#{r}"}
        end.flatten.include?(role_fullname)
      end
    end

    def connection
      @conn ||= Faraday::Connection.new(:url => ENDPOINT) do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Adapter::NetHttp
        builder.options.params_encoder = Faraday::FlatParamsEncoder
      end
    end
  end

  class BulkDashboardMaker
    def load_config
      @yaml = YAML.load_file("config.yml")
    end

    def bulk_create
      load_config
      client = Client.new
      old_id = client.search_dashboard_id_by_urlpath(@yaml['urlPath'])
      client.delete_dashboard(old_id) unless old_id.nil?
      payload = Dashboard.new.build(@yaml)
      client.create_dashboard(payload)
    end
  end

  class Dashboard
    attr_reader :title
    attr_reader :urlPath
    attr_reader :memo
    attr_reader :widgets

    def build(yaml)
      @title   = yaml["title"] || ""
      @urlPath = yaml["urlPath"] || "error"
      @memo    = yaml["memo"] || ""
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

      self.to_json
    end

    def to_json
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

    def build(y, param)
    end

    def max_width
      (MAX_COLUMN / ranges.size).to_i
    end

    def height
      6 #default
    end

    def row_height
      6 #All type adopted
    end

    def make_layout(y, i)
      {
        "x" => max_width * i,
        "y" => y,
        "height" => row_height,
        "width" => 6
      }
    end

    def ranges
      @ranges ||= [
        {},
        {"type" => "relative", "period" => 21600, "offset" => 0},
        {"type" => "relative", "period" => 259200, "offset" => 0},
        {"type" => "relative", "period" => 2592000, "offset" => 0}
      ]
    end
  end

  class HeaderGroup < WidgetGroup
    def build(y, param)
      param['markdowns'].map.with_index do |mkd, i|
        {
          "type" => "markdown",
          "title" => "",
          "layout" => make_layout(y, i),
          "markdown" => mkd
        }
      end
    end

    def height
      2
    end

    def row_height
      2
    end
  end

  class RoleGroup < WidgetGroup
    def build(y, param)
      ranges.map.with_index do |range, i|
        _tmp_obj = {
          "type" => "graph",
          "title" => "",
          "layout" => make_layout(y, i),
          "graph" => param,
        }
        _tmp_obj['range'] = range unless range.empty?
        _tmp_obj
      end
    end

    def height
      6
    end
    def row_height
      6
    end
  end

  class HostGroup < WidgetGroup
    def build(y, param)
      get_host_ids(param['roleFullname']).map.with_index do |id, i|
        ranges.map.with_index do |range, j|
          _tmp_obj = {
            "type" => "graph",
            "title" => "",
            "layout" => make_layout(y + HEIGHT * i, j),
            "graph" => {
              "type" => "host",
              "hostId" => id,
              "name" => param["name"]
            }
          }
          _tmp_obj['range'] = range unless range.empty?
          _tmp_obj
        end
      end.flatten
    end

    HEIGHT = 6
    def height
      @ids.nil? ? raise("Please call after #get_host_ids") : @ids.size * HEIGHT
    end

    def row_height
      HEIGHT
    end

    def get_host_ids(role_fullname)
      @ids = ObjectCache::read(role_fullname)
      if @ids.nil?
        hosts = Client.new.list_hosts_with_role(role_fullname)
        @ids = hosts.sort{|a,b| a["name"] <=> b["name"]}.map{|host| host['id']}
        ObjectCache::write(role_fullname, @ids)
      end
      @ids
    end
  end
end

#puts Mackerel::BulkDashboardMaker.new.bulk_create
Mackerel::BulkDashboardMaker.new.bulk_create
