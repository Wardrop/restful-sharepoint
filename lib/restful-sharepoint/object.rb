module RestfulSharePoint
  class Object

    def initialize(parent: nil, connection: nil, properties: nil, id: nil)
      raise Error, "Either a parent or connection must be provided." unless parent || connection
      @connection = connection || @parent.connection
      @properties = properties
      @id = id
    end

    attr_accessor :connection

    attr_writer :endpoint
    def endpoint
      @endpoint || (raise NotImplementedError, "Endpoint needs to be set")
    end

    def properties=(properties)
      @properties = properties
      @properties.each do |k,v|
        if v['__deferred']
          define_method k do
            fetch_deferred(k)
          end
        end
      end
    end

    def properties
      @properties || self.properties = connection.get(endpoint)
    end

    def fetch_deferred(property)
      @properties[property] = connection.get @properties[property]['deferred']['uri']
    end

    def method_missing(method, *args)
      properties.respond_to?(method) ? properties.send(method, *args) : super
    end

    def respond_to_missing?(method, include_all = false)
      properties.respond_to?(method, include_all)
    end

  end
end
