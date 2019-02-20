module Mkrdashboards
  class Host < WidgetGroup
    def build(y, ranges, param)
      validate(param)
      return build_with_condition( y, ranges, param['roleFullname'], param['name'], method(:get_host_ids_with_role) ) unless param['roleFullname'].nil?
      return build_with_condition( y, ranges, param['hostname'], param['name'], method(:get_host_ids_with_name) ) unless param['hostname'].nil?
    end

    def build_with_condition(y, ranges, search_words, name,  host_ids_get_method)
      w = MAX_COLUMN / ranges.size
      host_ids_get_method.call(search_words).map.with_index do |id, i|
        ranges.map.with_index do |range, j|
          _tmp_obj = {
            "type" => "graph",
            "title" => "",
            "layout" => make_layout(y + HEIGHT * i, j, w),
            "graph" => {
              "type" => "host",
              "hostId" => id,
              "name" => name
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

    def get_host_ids_with_role(role)
      @ids = ObjectCache::read(role)
      if @ids.nil?
        hosts = Client.new.list_hosts_with_role(role)
        @ids = hosts.sort{|a,b| a["name"] <=> b["name"]}.map{|host| host['id']}
        ObjectCache::write(role, @ids)
      end
      @ids
    end

    def get_host_ids_with_name(hostname)
      @ids = ObjectCache::read(hostname)
      if @ids.nil?
        hosts = Client.new.list_hosts_with_name(hostname)
        @ids = hosts.sort{|a,b| a["name"] <=> b["name"]}.map{|host| host['id']}
        ObjectCache::write(hostname, @ids)
      end
      @ids
    end

    def validate(param)
      raise("Not found required key") if (param['roleFullname'].nil? && param['hostname'].nil?) || param['name'].nil?
    end
  end
end

