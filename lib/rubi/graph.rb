require 'set'

module Rubi
  module Edge
    attr_reader :endpoints, :weight

    def initialize one_endpoint, another_endpoint, weight = 1
      @endpoints = [one_endpoint, another_endpoint]
      @weight = weight
    end

    def eql? other
      # Subclasses must implement hash for #eql? to make sense.
      hash.eql? other.hash
    end

    alias == eql?

    def adjacent_vertex_of vertex
      # To check that 'vertex' belongs to the edge could save some time
      # to someone someday.
      @endpoints.each do |endpoint|
        return endpoint unless endpoint.eql? vertex
      end
    end
  end

  class DirectedEdge
    include Edge

    def hash
      @endpoints.hash
    end

    def head
      @endpoints.last
    end

    def tail
      @endpoints.first
    end

    # def to_undirected_edge
    #   UndirectedEdge.new *@endpoints
    # end
  end

  class UndirectedEdge
    include Edge

    def hash
      @endpoints.first.hash ^ @endpoints.last.hash
    end
  end

  # class LoopEdge
  #   include Edge
  # end

  # class Property; end

  class Path
    include Edge

    attr_reader :edges

    def initialize *edges
      @edges = edges

      @endpoints = @edges.map(&:endpoints).inject { |result, edge|
        (result | edge) - (result & edge)
      }

      @weight = @edges.inject(0) { |sum, edge| sum + edge.weight }
    end

    # def last
    #   @edges.last
    # end

    # def first
    #   @edges.first
    # end

    # def map! &blk
    #   @edges.map! &blk
    # end

    # def push edge
    #   @edges.push edge

    #   return self
    # end

    def length
      @edges.length
    end

    def hash
      @edges.hash ^ @edges.reverse.hash
    end
  end

  class Graph
    def initialize *edges
      @incidence_list = Hash.new { |hash, key| hash[key] = Set.new }

      add_edges *edges
    end

    def add_edges *edges
      edges.each { |edge| add_edge edge }
    end

    def vertices
      @incidence_list.keys
    end

    def incident_edges vertex, adjacent_vertex = nil
      if adjacent_vertex
        @incidence_list[vertex].select { |edge| edge.endpoints.include? adjacent_vertex }
      else
        @incidence_list[vertex]
      end
    end

    def adjacent_vertices vertex
      @incidence_list[vertex].map(&:endpoints).flatten.uniq.reject { |v| v == vertex }
    end

    # def outgoing_edges vertex
    #   @incidence_list[vertex].select { |edge| edge.is_a? DirectedEdge and edge.tail.eql? vertex }
    # end

    # def incoming_edges vertex
    #   @incidence_list[vertex].select { |edge| edge.is_a? DirectedEdge and edge.head.eql? vertex }
    # end

    def eql? other
      @incidence_list.eql? other.instance_variable_get(:@incidence_list)
    end

    alias == eql?

    private

    def add_edge edge
      edge.endpoints.each { |endpoint| @incidence_list[endpoint] << edge }
    end
  end # Graph
end # Rubi
