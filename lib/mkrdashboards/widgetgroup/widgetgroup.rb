module Mkrdashboards
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
end
