require 'set'

module Rubi
  module Edge
    attr_reader :endpoints, :weight
    
    def initialize one_endpoint, another_endpoint, weight = 1
      @endpoints = [one_endpoint, another_endpoint]
      @weight = weight
    end

    def eql? other
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
      self.class.hash ^ @endpoints.hash
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
      self.class.hash ^ @endpoints.first.hash ^ @endpoints.last.hash
    end
  end

  # class LoopEdge
  #   include Edge
  # end

  # class Property; end

  class Path
    attr_reader :endpoints, :edges

    def initialize *edges
      @edges = edges

      hash = Hash.new(0)

      @edges.map(&:endpoints).flatten.each { |vertex|
        hash[vertex] += 1
      }

      @endpoints = hash.select { |k,v| v == 1 }.keys.sort
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

    def eql? other
      @edges.eql? other.edges
    end

    alias == eql?
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

    def incident_edges vertex
      @incidence_list[vertex]
    end

    # def adjacent_vertices vertex
    #   @incidence_list[vertex].map(&:endpoints).flatten.uniq.reject! { |v| v == vertex }
    # end

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

  class ShortestPathGraph < Graph
    attr_reader :source_vertex

    def initialize *edges, source_vertex
      super *edges
      @source_vertex = source_vertex
    end
  end # ShortestPathGraph
end # Rubi
