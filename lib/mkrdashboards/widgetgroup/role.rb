module Mkrdashboards
  class Role < WidgetGroup
    def build(y, param)
      ranges.map.with_index do |range, i|
        _tmp_obj = {
          "type" => "graph",
          "title" => "",
          "layout" => make_layout(y, i),
          "graph" => param,
        }
        _tmp_obj['range'] = range unless range.empty?
        _tmp_obj
      end
    end

    def height
      6
    end
    def row_height
      6
    end
  end
end
