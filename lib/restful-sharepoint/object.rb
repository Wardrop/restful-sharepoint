module RestfulSharePoint
  class Object < CommonBase
    DEFAULT_OPTIONS = {}

    include Enumerable
    extend Forwardable

    def_delegators :properties, :length, :keys

    def initialize(parent: nil, connection: nil, properties: nil, id: nil, options: {})
      raise Error, "Either a parent or connection must be provided." unless parent || connection
      @parent = parent
      @connection = @parent ? @parent.connection : connection
      self.properties = properties
      @id = id
      self.options = options
    end

    attr_accessor :connection
    attr_reader :options
    def options=(options)
      @options = self.class::DEFAULT_OPTIONS.merge(options)
    end

    attr_writer :endpoint
    def endpoint
      @endpoint || self['__metadata']['uri'] || (raise NotImplementedError, "Endpoint could not be determined")
    end

    attr_writer :properties
    def properties
      @properties || self.properties = connection.get(endpoint, options: @options)
    end

    def [](key, options = {})
      if connection.objectified?(properties[key])
        warn "`options` have been ignored as deferred object has already been fetched" unless options.empty?
        properties[key]
      elsif properties[key].respond_to?('[]') && properties[key]['__deferred']
        properties[key] = fetch_deferred(key, options)
      else
        properties[key] = connection.objectify(properties[key])
      end
    end

    def ==(other)
      other.== properties
    end

    def eql?(other)
      other.eql? properties
    end

    def to_h
      hash = {}
      properties.each do |k,v|
        hash[k] = case v
        when Object
          v.to_h
        when Collection
          v.to_a
        else
          v
        end
      end
    end
    alias to_hash to_h

    def fetch_deferred(property, options = {})
      connection.get_as_object(@properties[property]['__deferred']['uri'], options: options)
    end

    def to_json(*args, &block)
      properties.to_json(*args, &block)
    end

    def each(&block)
      properties.each do |k,v|
        yield k, self[k]
      end
    end

  end
end
