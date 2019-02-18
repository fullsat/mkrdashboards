require 'spec_helper'
require 'json'

RSpec.describe Mkrdashboards::Host do
  before do
    ENV['MACKEREL_APIKEY'] = 'xxxxxxxxxxxxxxxxx'
  end

  # farady mock
  let(:hosts_list) {
    { "hosts" => 
      [
        {
          "id" => "3x1mrnrn1Z9",
          "name" => "rinze",
          "status" => "working",
          "isRetired" => false,
          "createdAt" => "2019-02-03T15:19:10+09:00",
          "roles" => {
            "tsubasa" => [ "web", "plove"]
          },
          "ipAddresses" => {
            "wlp3s0" => "10.0.10.19"
          }
        },
        {
          "id" => "3y9Chlgu4xs",
          "name" => "kaho",
          "status" => "working",
          "isRetired" => false,
          "createdAt" => "2019-02-03T15:19:10+09:00",
          "roles" => {
            "tsubasa" => [ "web", "genki"]
          },
          "ipAddresses" => {
            "wlp3s0" => "10.0.7.29"
          }
        }
      ]
    }
  }
  let(:hosts_con) {
    Faraday.new do |conn|
      conn.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/v0/hosts") do
          [
            200,
            {},
            hosts_list.to_json
          ] # status code, response header, response body
        end
      end
    end
  }
  # ==end farady mock

  let(:y) { 0 }
  let(:ranges) { 
      [
        {},
        {"type" => "relative", "period" => 21600, "offset" => 0},
        {"type" => "relative", "period" => 259200, "offset" => 0},
        {"type" => "relative", "period" => 2592000, "offset" => 0}
      ]
  }
  let(:bad_params) {
    {
      "type" => "host",
      "roleFullname" => "tsubasa:web"
    }
  }
  let(:good_params) {
    {
      "type" => "host",
      "roleFullname" => "tsubasa:web",
      "name" => "filesystem"
    }
  }
  let(:host) { Mkrdashboards::Host.new }
  let(:expect_value) {
    [
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 0, "y" => 0, "height" => 6, "width" => 6},
        "graph" => {
          "type" => "host",
          "hostId" => "3y9Chlgu4xs",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 6, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 21600, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3y9Chlgu4xs",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 12, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 259200, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3y9Chlgu4xs",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 18, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 2592000, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3y9Chlgu4xs",
          "name" => "filesystem"
        }
      },


      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 0, "y" => 6, "height" => 6, "width" => 6},
        "graph" => {
          "type" => "host",
          "hostId" => "3x1mrnrn1Z9",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 6, "y" => 6, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 21600, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3x1mrnrn1Z9",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 12, "y" => 6, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 259200, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3x1mrnrn1Z9",
          "name" => "filesystem"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 18, "y" => 6, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 2592000, "offset" => 0},
        "graph" => {
          "type" => "host",
          "hostId" => "3x1mrnrn1Z9",
          "name" => "filesystem"
        }
      }
    ]
  }

  it "return greater than 6" do
    expect(host.row_height).to be >= 6
  end

  it "can not calculate total height because does not know hosts" do
    expect{ host.height }.to raise_error("Please call after #get_host_ids")
    
  end

  it "builds valid hash_object" do
    allow_any_instance_of(Mkrdashboards::Client).to receive(:connection).and_return(hosts_con)
    expect( host.build(y, ranges, good_params) ).to eq(expect_value)
  end

  it "raise exception" do
    expect{ host.build(y, ranges, bad_params) }.to raise_error("Not found required key")
  end
end
