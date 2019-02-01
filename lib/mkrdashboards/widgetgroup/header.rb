module Mkrdashboards
  class Header < WidgetGroup
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
end
