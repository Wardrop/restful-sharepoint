module RestfulSharePoint
  class CommonBase
    # Converts the given enumerable tree to a collection or object.
    def objectify(tree)
      if tree['results'] && !tree['results'].empty?
        type = tree.dig('__metadata', 'type')  || tree.dig('results', 0, '__metadata', 'type')
        pattern, klass = COLLECTION_MAP.find { |pattern,| pattern.match(type)  }
        klass ? RestfulSharePoint.const_get(klass).new(parent: self, collection: tree['results']) : tree['results']
      elsif tree['__metadata']
        type = tree['__metadata']['type']
        pattern, klass = OBJECT_MAP.find { |pattern,| pattern.match(type)  }
        klass ? RestfulSharePoint.const_get(klass).new(parent: self, properties: tree) : tree
      end
    end
  end
end
