# 1. Get shortest paths between target vertices of a connected graph.
# 2. Conform a complete graph of target vertices (nodes) and shortest paths (edges).
# 3. Find the minimum spanning trees of the complete graph.
# 4. Expand the minimum spanning trees into spanning tres of the original graph.

require 'algorithms'

class MinPriorityQueue < Containers::Heap
  def initialize
    super { |a, b| a.distance < b.distance }
  end

  def push vertex, distance
    super vertex_key(vertex, distance), vertex
  end

  def decrease_priority vertex, old_distance, new_distance
    change_key vertex_key(vertex, old_distance), vertex_key(vertex, new_distance)
  end

  private

  def vertex_key vertex, distance
    VertexKey.new vertex, distance
  end

  VertexKey = Struct.new :vertex, :distance
end # MinPriorityQueue

module Rubi
  class Matroid
    def self.solve path_ground_set, target_vertices
      minimum_weight = Float::INFINITY
      independent_sets = Set.new
      target_vertices = Set.new target_vertices
      rank = target_vertices.length - 1

      path_ground_set.combination(rank).each do |path_combination|
        if path_combination.map(&:endpoints).flatten.to_set == target_vertices
          # This could be the comparison of two arrays. I chose to compare sets because
          # I do not want to sort the arrays in order to compare them; :sort relies on :<=>
          # method, since any object can be a vertex this could be a problem as not
          # all objects implement the aforementioned method.

          # Following code executes if path_combination is an independet set.
      
          edge_set = path_combination.map(&:edges).inject(Set.new) { |p, q| p.union q }

          if edge_set.size < minimum_weight
            minimum_weight = edge_set.size
            independent_sets.clear << edge_set
          elsif edge_set.size == minimum_weight
            independent_sets << edge_set
          end

        end # if
      end # each

      return independent_sets
    end # ::solve
  end # Matroids

  class Dijkstra
    # https://github.com/monora/rgl/blob/master/lib/rgl/dijkstra.rb
    # http://en.wikipedia.org/wiki/Dijkstra's_algorithm
    #
    # The current implementation modifies the original algorithm
    # to support parallel edges and to return every shortest path possible.

    def self.solve graph, source_vertex
      distance = Hash.new(Float::INFINITY)
      distance[source_vertex] = 0
      
      heap = MinPriorityQueue.new

      graph.vertices.each do |vertex|
        heap.push vertex, distance[vertex]
      end

      scanned = Hash.new
      shortest_path_graph = Array.new

      until heap.empty?
        vertex = heap.pop
        scanned[vertex] = true

        graph.adjacent_vertices(vertex).each do |neighbour_vertex|
          unless scanned[neighbour_vertex]
            edges = Array.new
            minimum_weight = Float::INFINITY

            graph.incident_edges(vertex, neighbour_vertex).each do |edge|
              if edge.weight < minimum_weight
                minimum_weight = edge.weight
                edges.clear << edge
              elsif edge.weight == minimum_weight
                edges << edge
              end
            end

            new_distance = distance[vertex] + minimum_weight

            if new_distance < distance[neighbour_vertex]
              heap.decrease_priority neighbour_vertex, distance[neighbour_vertex], new_distance
              distance[neighbour_vertex] = new_distance

              shortest_path_graph.concat edges
            elsif new_distance == distance[neighbour_vertex]
              shortest_path_graph.concat edges
            end
          end # unless scanned[vertex]
        end # graph.adjacent_vertices
      end # until heap.empty?

      return ShortestPathGraph.new *shortest_path_graph, source_vertex
    end # ::solve

    def self.shortest_paths shortest_path_graph, target_vertex
      stack = Array.new
      shortest_paths = Array.new

      shortest_path_graph.incident_edges(shortest_path_graph.source_vertex).each do |edge|
        stack.push [edge]
      end

      until stack.empty?
        path = stack.pop

        if path.last.endpoints.include? target_vertex
          shortest_paths << path
        else
          shortest_path_graph.incident_edges(path.last.head).each do |edge|
            stack.push(path.dup << edge)
          end
        end
      end

      shortest_paths.map! do |path|
        Path.new *path
      end

      return shortest_paths
    end # ::shortest_paths
  end # Dijkstra

  class Graph
    def spanning_trees *target_vertices
      shortest_path_graphs = target_vertices.slice(0...-1).map do |vertex|
        Dijkstra.solve self, vertex
      end

      shortest_paths = Array.new

      shortest_path_graphs.each_with_index do |graph, index|
        target_vertices.slice((index + 1)..-1).each do |vertex|
          shortest_paths.concat Dijkstra.shortest_paths(graph, vertex)
        end
      end

      Matroid.solve shortest_paths, target_vertices
    end # #shortest_paths
  end # Graph

end # Rubi
