require 'set'

module Rubi
  class Edge
    attr_reader :endpoints

    def initialize one_endpoint, another_endpoint
      @endpoints = [one_endpoint, another_endpoint]
    end

    # def <=> another_edge
    #   object_id <=> another_edge.object_id
    # end
  end

  class DirectedEdge < Edge
    def head
      @endpoints.last
    end

    def tail
      @endpoints.first
    end
  end

  class UndirectedEdge < Edge; end
  class LoopEdge < Edge; end
  class Property; end

  class Path
    attr_reader :endpoints, :edges

    def initialize *edges
      @edges = edges.sort

      hash = Hash.new(0)

      edges.map(&:endpoints).flatten.each { |vertex|
        hash[vertex] += 1
      }

      @endpoints = hash.select { |k,v| v == 1 }.keys.sort
    end

    def length
      @edges.length
    end
  end

  class Graph
    def initialize
      @incidence_list = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add_edge edge
      edge.endpoints.each { |endpoint| @incidence_list[endpoint] << edge }
    end

    def add_edges *edges
      edges.each { |edge| add_edge edge }
    end

    def adjacent_vertices vertex
      @incidence_list[vertex].map(&:endpoints).uniq.select { |adjacent_vertex| adjacent_vertex != vertex }
    end
  end
end
