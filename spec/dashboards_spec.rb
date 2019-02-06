require 'spec_helper'
require 'json'

RSpec.describe Mkrdashboards do
  before do
    ENV['MACKEREL_APIKEY'] = 'xxxxxxxxxxxxxxxxx'
  end
  let(:dashboard) { Mkrdashboards::Dashboard.new }

  # farady mock
  let(:empty_hosts_con) {
    Faraday.new do |conn|
      conn.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("/api/v0/hosts") do
          [200, {}, {}.to_json ] # status code, response header, response body
        end
      end
    end
  }
  # ==end farady mock

  # params pattern
  let(:ranges) { ["nil","6h","3d","1mo"] }
  let(:title) { "Everybody Let's GO" }
  let(:empty_object) { {} }
  let(:right_object) {
    rowr = bad_object
    rowr['ranges'] = ranges
    rowr['title'] = title
    rowr 
  }
  let(:right_object_without_ranges) {
    rowr = bad_object
    rowr['title'] = title
    rowr 
  }
  let(:bad_object) { 
    {
      "urlPath" => "after_school_climax_girls",
      "widget_params" => [
        {
          "type" => "header",
          "markdowns" => [
            "at After School",
            "6 hours ago",
            "3 days ago",
            "1 month ago"
          ]
        },
        {
          "type" => "host",
          "roleFullname" => "lab:web",
          "name" => "filesystem"
        },
        {
          "type" => "role",
          "roleFullname" => "lab:web",
          "name" => "custom.multicore.loadavg_per_core.loadavg5"
        }
      ]
    }
  }
  # ==end parameter pattern
  let(:expect_value){
    {"title"=>"Everybody Let's GO", "urlPath"=>"after_school_climax_girls", "memo"=>"", "widgets"=>[{"type"=>"markdown", "title"=>"", "layout"=>{"x"=>0, "y"=>0, "height"=>2, "width"=>6}, "markdown"=>"at After School"}, {"type"=>"markdown", "title"=>"", "layout"=>{"x"=>6, "y"=>0, "height"=>2, "width"=>6}, "markdown"=>"6 hours ago"}, {"type"=>"markdown", "title"=>"", "layout"=>{"x"=>12, "y"=>0, "height"=>2, "width"=>6}, "markdown"=>"3 days ago"}, {"type"=>"markdown", "title"=>"", "layout"=>{"x"=>18, "y"=>0, "height"=>2, "width"=>6}, "markdown"=>"1 month ago"}, {"type"=>"graph", "title"=>"", "layout"=>{"x"=>0, "y"=>2, "height"=>6, "width"=>6}, "graph"=>{"type"=>"role", "roleFullname"=>"lab:web", "name"=>"custom.multicore.loadavg_per_core.loadavg5"}}, {"type"=>"graph", "title"=>"", "layout"=>{"x"=>6, "y"=>2, "height"=>6, "width"=>6}, "graph"=>{"type"=>"role", "roleFullname"=>"lab:web", "name"=>"custom.multicore.loadavg_per_core.loadavg5"}, "range"=>{"type"=>"relative", "period"=>21600, "offset"=>0}}, {"type"=>"graph", "title"=>"", "layout"=>{"x"=>12, "y"=>2, "height"=>6, "width"=>6}, "graph"=>{"type"=>"role", "roleFullname"=>"lab:web", "name"=>"custom.multicore.loadavg_per_core.loadavg5"}, "range"=>{"type"=>"relative", "period"=>259200, "offset"=>0}}, {"type"=>"graph", "title"=>"", "layout"=>{"x"=>18, "y"=>2, "height"=>6, "width"=>6}, "graph"=>{"type"=>"role", "roleFullname"=>"lab:web", "name"=>"custom.multicore.loadavg_per_core.loadavg5"}, "range"=>{"type"=>"relative", "period"=>2592000, "offset"=>0}}]}
  }

  it "raises a exception" do
    expect{ dashboard.build(empty_object) }.to raise_error("NOT a valid format error")
    expect{ dashboard.build(bad_object) }.to raise_error("NOT a valid format error")
  end

  it "returns a json object" do
    allow_any_instance_of(Mkrdashboards::Client).to receive(:connection).and_return(empty_hosts_con)
    json_ro   = dashboard.build( right_object )
    json_rowr = dashboard.build( right_object_without_ranges )
    expect( JSON.parse( json_ro ) ).to eq(expect_value)
    expect( JSON.parse( json_rowr ) ).to eq(expect_value)
  end
end
