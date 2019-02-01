module Mkrdashboards
  class Dashboard
    attr_reader :title
    attr_reader :urlPath
    attr_reader :memo
    attr_reader :widgets

    def build(yaml)
      @title   = yaml['title'] || ''
      @urlPath = yaml['urlPath'] || 'error'
      @memo    = yaml['memo'] || ''
      @widgets = []

      y = 0

      wgf = WidgetGroupFactory.new
      yaml['widget_params'].each do |param, i|
        group = wgf.create(param['type'])
        group.build(y, param).each do |widget|
          @widgets << widget
        end
        y += group.height
      end

      self.to_json
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
