module Mkrdashboards
  class WidgetGroup
    MAX_COLUMN = 24
    attr_reader :row

    def build(y, ranges, param)
    end

    def height
      6 #default
    end

    def row_height
      6 #All type adopted
    end

    def make_layout(y, i, w)
      {
        "x" => w * i,
        "y" => y,
        "height" => row_height,
        "width" => 6
      }
    end
  end
end
