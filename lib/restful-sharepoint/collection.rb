module RestfulSharePoint
  class Collection < CommonBase
    DEFAULT_OPTIONS = {}

    def self.object_class
      Object
    end

    def initialize(parent: nil, connection: nil, collection: nil, options: {})
      @parent = parent
      @connection = connection || @parent.connection # Iterate collection and coerce each into into a ListItem
      self.collection = collection
      self.options = options
    end

    attr_accessor :connection

    attr_reader :options
    def options=(options)
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

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
      @collection || self.collection = connection.get(endpoint, options: @options)
    end

    def values
      collection.dup.each { |k,v| properties[k] = v.values if v.is_a?(Object) || v.is_a?(Collection) }
    end

    def next
      self.new(@connection, @connection.get(collection['__next']))
    end

    def to_json(*args, &block)
      collection.to_json(*args, &block)
    end

    def method_missing(method, *args, &block)
      collection.respond_to?(method) ? collection.send(method, *args, &block) : super
    end

    def respond_to_missing?(method, include_all = false)
      collection.respond_to?(method, include_all)
    end
  end
end
