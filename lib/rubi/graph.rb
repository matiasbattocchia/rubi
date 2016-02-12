module Rubi
  class Edge
    attr_reader :endpoints, :properties

    def initialize(one_endpoint, another_endpoint, properties = {})
      @endpoints = [one_endpoint, another_endpoint]
      @properties = properties
    end

    def hash
      @endpoints.first.hash ^ @endpoints.last.hash ^ @properties.hash
    end

    def ==(other)
      hash == other.hash
    end

    alias eql? ==

    def adjacent_vertex_of(vertex)
      @endpoints.each do |endpoint|
        return endpoint unless endpoint == vertex
      end
    end
  end

  class DirectedEdge < Edge
    def hash
      @endpoints.hash ^ @properties.hash
    end

    def head
      @endpoints.last
    end

    def tail
      @endpoints.first
    end
  end

  class Path < Edge
    attr_reader :edges

    def initialize(*edges)
      @edges = edges

      @endpoints = @edges.map(&:endpoints)
        .reduce { |result, edge| (result | edge) - (result & edge) }
    end

    def hash
      @edges.hash ^ @edges.reverse.hash
    end

    def size
      @edges.size
    end
  end

  class Graph
    attr_reader :incidence_list

    def initialize(*edges)
      @incidence_list = Hash.new { |hash, key| hash[key] = Set.new }

      add_edges(*edges)
    end

    def add_edge(edge)
      edge.endpoints.each { |endpoint| @incidence_list[endpoint] << edge }
    end

    def add_edges(*edges)
      edges.each { |edge| add_edge(edge) }
    end

    def edges
      @incidence_list.values
    end

    def incident_edges(vertex, adjacent_vertex = nil)
      if adjacent_vertex
        @incidence_list.fetch(vertex)
          .select { |edge| edge.endpoints.include?(adjacent_vertex) }
      else
        @incidence_list.fetch(vertex)
      end
    end

    def add_vertex(vertex)
      @incidence_list[vertex]
    end

    def add_vertices(*vertices)
      vertices.each { |vertex| add_vertex(vertex) }
    end

    def vertices
      @incidence_list.keys
    end

    def adjacent_vertices(vertex)
      @incidence_list.fetch(vertex).map(&:endpoints).flatten.uniq
        .reject { |v| v == vertex }
    end

    def ==(other)
      @incidence_list == other.incidence_list
    end

    alias eql? ==
  end
end
