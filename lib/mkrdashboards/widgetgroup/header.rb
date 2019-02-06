module Mkrdashboards
  class Header < WidgetGroup
    def build(y, ranges, param)
      validate(ranges, param)

      w = MAX_COLUMN / ranges.size
      param['markdowns'].map.with_index do |mkd, i|
        {
          "type" => "markdown",
          "title" => "",
          "layout" => make_layout(y, i, w),
          "markdown" => mkd
        }
      end
    end

    def validate(ranges, param)
      raise("Not found 'markdowns' key") if param['markdowns'].nil?
      raise("Wrong size of array") unless param['markdowns'].size == ranges.size
    end

    def height
      2
    end

    def row_height
      2
    end
  end
end
