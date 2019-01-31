require 'spec_helper'
require 'json'

RSpec.describe Mkrdashboards::Role do
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
      "type" => "role",
      "roleFullname" => "tsubasa:web"
    }
  }
  let(:good_params) {
    {
      "type" => "role",
      "roleFullname" => "tsubasa:web",
      "name" => "custom.multicore.loadavg_per_core.loadavg5"
    }
  }
  let(:role) { Mkrdashboards::Role.new }
  let(:expect_value) {
    [
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 0, "y" => 0, "height" => 6, "width" => 6},
        "graph" => {
          "type" => "role",
          "roleFullname"=>"tsubasa:web",
          "name" => "custom.multicore.loadavg_per_core.loadavg5"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 6, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 21600, "offset" => 0},
        "graph" => {
          "type" => "role",
          "roleFullname"=>"tsubasa:web",
          "name" => "custom.multicore.loadavg_per_core.loadavg5"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 12, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 259200, "offset" => 0},
        "graph" => {
          "type" => "role",
          "roleFullname"=>"tsubasa:web",
          "name" => "custom.multicore.loadavg_per_core.loadavg5"
        }
      },
      {
        "type" => "graph",
        "title" => "",
        "layout" => {"x" => 18, "y" => 0, "height" => 6, "width" => 6},
        "range" => {"type" => "relative", "period" => 2592000, "offset" => 0},
        "graph" => {
          "type" => "role",
          "roleFullname"=>"tsubasa:web",
          "name" => "custom.multicore.loadavg_per_core.loadavg5"
        }
      }
    ]
  }

  it "return greater than 6" do
    expect(role.height).to be >= 6
    expect(role.row_height).to be >= 6
  end

  it "builds valid hash_object" do
    expect( role.build(y, ranges, good_params) ).to eq(expect_value)
  end

  it "raise exception" do
    expect{ role.build(y, ranges, bad_params) }.to raise_error("Not found required key")
  end
end
