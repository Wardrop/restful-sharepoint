module RestfulSharePoint
  class Object
    DEFAULT_OPTIONS = {}

    def initialize(parent: nil, connection: nil, properties: nil, id: nil, options: {})
      raise Error, "Either a parent or connection must be provided." unless parent || connection
      @parent = parent
      @connection = connection || @parent.connection
      self.properties = properties
      @id = id
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    attr_accessor :connection

    attr_writer :endpoint
    def endpoint

    end

    def properties=(properties)
      @properties = properties
      @properties&.each do |k,v|
        if v.respond_to?(:keys) && v['__deferred']
          define_singleton_method(k) do
            if Hash === properties[k] && properties[k]['__deferred']
              fetch_deferred(k)
            else
              properties[k]
            end
          end
        elsif v.respond_to?(:keys) && (v['__metadata'] || v['results'])
          @properties[k] = objectify(v)
        end
      end
      @properties
    end

    def properties
      @properties || self.properties = connection.get(endpoint, @options)
    end

    def fetch_deferred(property)
      data = connection.get @properties[property]['__deferred']['uri']
      @properties[property] = objectify(data)
    end

    def method_missing(method, *args, &block)
      if properties.respond_to?(method)
        properties.send(method, *args, &block)
      elsif self.methods(false).include?(method) # Works around lazily loaded `properties`
        self.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_all = false)
      properties.respond_to?(method, include_all)
    end

    # Converts the given enumerable tree to a collection or object.
    def objectify(tree)
      if Array === tree && !tree.empty?
        pattern, klass = COLLECTION_MAP.find { |pattern,| pattern.match(tree[0]['__metadata']['type'])  }
        klass ? RestfulSharePoint.const_get(klass).new(parent: self, collection: tree) : tree
      elsif tree['__metadata']
        pattern, klass = OBJECT_MAP.find { |pattern,| pattern.match(tree['__metadata']['type'])  }
        klass ? RestfulSharePoint.const_get(klass).new(parent: self, properties: tree) : tree
      end
    end

  end
end
