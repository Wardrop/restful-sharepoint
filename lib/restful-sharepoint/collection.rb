module RestfulSharePoint
  class Collection
    DEFAULT_OPTIONS = {}

    def self.object_class
      Object
    end

    def initialize(parent: nil, connection: nil, collection: nil, options: {})
      @parent = parent
      @connection = connection || @parent.connection # Iterate collection and coerce each into into a ListItem
      self.collection = collection
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    attr_accessor :connection

    attr_writer :endpoint
    def endpoint
      @endpoint || (raise NotImplementedError, "Endpoint needs to be set")
    end

    def collection=(collection)
      @collection = collection
      @collection&.each_with_index do |v,i|
        @collection[i] = objectify(v)
      end
      @properties
    end

    def collection
      @collection || self.collection = connection.get(endpoint)
    end

    def next
      self.new(@connection, @connection.get(@collection['__next']))
    end

    def method_missing(method, *args, &block)
      collection.respond_to?(method) ? collection.send(method, *args, &block) : super
    end

    def respond_to_missing?(method, include_all = false)
      collection.respond_to?(method, include_all)
    end

    # Converts the given enumerable tree to a collection or object.
    def objectify(tree)
      if tree['__metadata']
        pattern, klass = OBJECT_MAP.find { |pattern,| pattern.match(tree['__metadata']['type'])  }
        klass ? RestfulSharePoint.const_get(klass).new(parent: self, properties: tree) : tree
      end
    end
  end
end
