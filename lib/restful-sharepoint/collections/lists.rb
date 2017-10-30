module RestfulSharePoint
  class Lists < Collection

    def self.object_class
      List
    end

    def endpoint
      "#{@parent.endpoint}/Lists"
    end

  end
end
