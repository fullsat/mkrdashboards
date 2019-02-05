module Mkrdashboards
  class Host < WidgetGroup
    def build(y, ranges, param)
      w = MAX_COLUMN / ranges.size
      get_host_ids(param['roleFullname']).map.with_index do |id, i|
        ranges.map.with_index do |range, j|
          _tmp_obj = {
            "type" => "graph",
            "title" => "",
            "layout" => make_layout(y + HEIGHT * i, j, w),
            "graph" => {
              "type" => "host",
              "hostId" => id,
              "name" => param["name"]
            }
          }
          _tmp_obj['range'] = range unless range.empty?
          _tmp_obj
        end
      end.flatten
    end

    HEIGHT = 6
    def height
      @ids.nil? ? raise("Please call after #get_host_ids") : @ids.size * HEIGHT
    end

    def row_height
      HEIGHT
    end

    def get_host_ids(role_fullname)
      @ids = ObjectCache::read(role_fullname)
      if @ids.nil?
        hosts = Client.new.list_hosts_with_role(role_fullname)
        @ids = hosts.sort{|a,b| a["name"] <=> b["name"]}.map{|host| host['id']}
        ObjectCache::write(role_fullname, @ids)
      end
      @ids
    end
  end
end

