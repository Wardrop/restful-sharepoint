module RestfulSharePoint
  class Webs < Collection

    def self.object_class
      Web
    end

    def endpoint
      "#{@parent}/Webs"
    end

  end
end
