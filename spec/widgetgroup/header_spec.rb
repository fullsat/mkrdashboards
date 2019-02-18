require 'spec_helper'
require 'json'

RSpec.describe Mkrdashboards::Header do
  let(:y) { 0 }
  let(:ranges) { ["nil","6h","3d","1mo"] }
  let(:empty_params) {
    {
      "type" => "header"
    }
  }

  let(:bad_params) {
    {
      "type" => "header",
      "markdowns" => [
        "at After School",
        "6 hours ago"
      ]
    }
  }
  let(:good_params) {
    {
      "type" => "header",
      "markdowns" => [
        "at After School",
        "6 hours ago",
        "3 days ago",
        "1 month ago"
      ]
    }
  }
  let(:header) { Mkrdashboards::Header.new }
  let(:expect_value) {
    [
      {
        "type" => "markdown",
        "title" => "",
        "layout" => {"x" => 0, "y" => 0, "height" => 2, "width" => 6},
        "markdown" => "at After School"
      },
      {
        "type" => "markdown",
        "title" => "",
        "layout" => {"x" => 6, "y" => 0, "height" => 2, "width" => 6},
        "markdown" => "6 hours ago"
      },
      {
        "type" => "markdown",
        "title" => "",
        "layout" => {"x" => 12, "y" => 0, "height" => 2, "width" => 6},
        "markdown" => "3 days ago"
      },
      {
        "type" => "markdown",
        "title" => "",
        "layout" => {"x" => 18, "y" => 0, "height" => 2, "width" => 6},
        "markdown" => "1 month ago"
      }
    ]
  }

  it "return greater than 2" do
    expect(header.height).to be >= 2
    expect(header.row_height).to be >= 2
  end

  it "builds valid hash_object" do
    expect( header.build(y, ranges, good_params) ).to eq(expect_value)
  end

  it "raise exception" do
    expect{ header.build(y, ranges, bad_params) }.to raise_error("Wrong size of array")
    expect{ header.build(y, ranges, empty_params) }.to raise_error("Not found 'markdowns' key")
  end
end
