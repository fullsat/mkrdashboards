require 'faraday'
require 'json'

module Mkrdashboards
  class Client
    ENDPOINT = "https://api.mackerelio.com/"

    def initialize
      exception_message = 'Environment Variable Not Found,'
      exception_message += 'Please specify Available MACKEREL_APIKEY'
      @apikey = ENV['MACKEREL_APIKEY'] || raise(exception_message)
    end

    def create_dashboard(payload)
      res = connection.post do |req|
        req.url '/api/v0/dashboards'
        req.headers['X-Api-Key'] = 
        req.headers['Content-Type'] = 'application/json'
        req.body = payload
      end
      res.body
    end

    def delete_dashboard(dashboard_id)
      res = connection.delete do |req|
        req.url "/api/v0/dashboards/#{dashboard_id}"
        req.headers['X-Api-Key'] = @apikey
        req.headers['Content-Type'] = 'application/json'
      end
      res.body
    end

    def search_dashboard_id_by_urlpath(url_path)
      dashboards = ObjectCache::read('dashboards')
      if dashboards.nil?
        res = connection.get do |req|
          req.url '/api/v0/dashboards'
          req.headers['X-Api-Key'] = @apikey
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
          req.headers['X-Api-Key'] = @apikey
          req.headers['Content-Type'] = 'application/json'
          req.params['status'] = ["working", "standby", "maintenance", "poweroff"]
      end

      hosts = JSON.parse(res.body)
      hosts['hosts'].select! do |host|
        host['roles'].map do |s, roles|
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
end
