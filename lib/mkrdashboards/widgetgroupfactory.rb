module Mkrdashboards
  class WidgetGroupFactory
    def create(name)
      case name
      when "role" then Role.new
      when "host" then Host.new
      when "header" then Header.new
      end
    end
  end
end
