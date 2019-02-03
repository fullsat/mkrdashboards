module Mkrdashboards
  class Header < WidgetGroup
    def build(y, ranges, param)
      w = ranges.size
      param['markdowns'].map.with_index do |mkd, i|
        {
          "type" => "markdown",
          "title" => "",
          "layout" => make_layout(y, i, w),
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
end
