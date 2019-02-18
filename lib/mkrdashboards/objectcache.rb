module Mkrdashboards
  class ObjectCache
    @@hash_objects = {}
    def self.write(key, object)
      @@hash_objects[key] = object
    end

    def self.read(key)
      @@hash_objects[key]
    end
  end
end
