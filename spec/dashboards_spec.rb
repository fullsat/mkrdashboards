require 'spec_helper'
require 'json'

RSpec.describe Mkrdashboards do
  let(:dashboard) { Mkrdashboards::Dashboard.new }

  # parameter pattern
  let(:empty_object) { {} }

  let(:right_object) { 
    {
      "title" => "Everybody Let's GO",
      "urlPath" => "after_school_climax_girls",
      "ranges" => [
        "nil",
        "6h",
        "3d",
        "1mo"
      ],
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

  it "raises a exception" do
    expect{ dashboard.build(empty_object) }.to raise_error("NOT a valid format error")
  end

  it "returns a json object" do
    json_object = dashboard.build( right_object )
    expect{ JSON.parse( json_object ) }.not_to raise_error(JSON::ParserError)
  end
end
