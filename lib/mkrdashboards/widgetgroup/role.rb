module Mkrdashboards
  class Role < WidgetGroup
    def build(y, ranges, param)
      validate(param)

      w = MAX_COLUMN / ranges.size
      ranges.map.with_index do |range, i|
        _tmp_obj = {
          "type" => "graph",
          "title" => "",
          "layout" => make_layout(y, i, w),
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

    def validate(param)
      raise("Not found required key") if param['roleFullname'].nil? || param['name'].nil?
    end

  end
end
