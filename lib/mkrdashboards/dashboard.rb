module Mkrdashboards
  class Dashboard
    attr_reader :title
    attr_reader :urlPath
    attr_reader :memo
    attr_reader :widgets

    def build(yaml)
      validate(yaml)

      @title   = yaml['title']
      @urlPath = yaml['urlPath']
      @memo    = yaml['memo'] || ""
      @ranges  = ranges_to_hash( yaml['ranges'] ) 
      widget_params = yaml['widget_params']

      y = 0
      wgf = WidgetGroupFactory.new
      @widgets = widget_params.inject([]) do |widgets, param|
        group = wgf.create(param['type'])
        widgets.concat( group.build(y, @ranges, param) )
        y += group.height
        widgets
      end

      self.to_json
    end

    def validate(yaml)
      no_required_params = yaml['title'].nil? || yaml['urlPath'].nil? || yaml['widget_params'].nil?
      raise("NOT a valid format error") if no_required_params
    end

    def ranges_to_hash(ranges)
      return default_ranges if ranges.nil?

      ranges.inject([]) do |_ranges, range|
        if range == "nil"
          _ranges << {}
        else
          /(\d+)(s|m|h|d|mo|y)$/ =~ range
          period = 0
          case $2
          when "s"  then period = $1.to_i
          when "m"  then period = $1.to_i * 60
          when "h"  then period = $1.to_i * 60 * 60
          when "d"  then period = $1.to_i * 60 * 60 * 24
          when "mo" then period = $1.to_i * 60 * 60 * 24 * 30
          when "y"  then period = $1.to_i * 60 * 60 * 24 * 365
          else
            raise("Format Error") if $1.nil?
          end
          _ranges << {
            "type" => "relative", "period" => period, "offset" => 0
          }
        end
      end
    end

    def default_ranges
      [
        {},
        {"type" => "relative", "period" => 43200, "offset" => 0},
        {"type" => "relative", "period" => 259200, "offset" => 0},
        {"type" => "relative", "period" => 7776000, "offset" => 0}
      ]
    end

    def to_json
      {
        "title" => self.title,
        "urlPath" => self.urlPath,
        "memo" => self.memo,
        "widgets" => self.widgets
      }.to_json
    end
  end
end
