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
end

module Rubi
  # class Combinations
  #   def self.combinations paths, target_vertices
  #     valid_combinations = paths.combination(target_vertices.sort!.length - 1).select { |combination|
  #       combination.map(&:endpoints).flatten.uniq.sort == target_vertices
  #     }

  #     current_length = Float::INFINITY

  #     combinations = []

  #     valid_combinations.map { |combination|
  #       combination = combination.map(&:edges).flatten.uniq.sort

  #       if combination.length == current_length
  #         combinations << combination
  #       elsif combination.length < current_length
  #         current_length = combination.length
  #         combinations = [combination]
  #       end
  #     }

  #     combinations.uniq.sort
  #   end
  # end

  class Dijkstra
    # https://github.com/monora/rgl/blob/master/lib/rgl/dijkstra.rb
    # http://en.wikipedia.org/wiki/Dijkstra's_algorithm

    def self.solve graph, source
      distance = Hash.new(Float::INFINITY)
      distance[source] = 0
      
      heap = MinPriorityQueue.new
      shortest_path_graph = Graph.new

      graph.vertices.each do |vertex|
        heap.push vertex, distance[vertex]
      end

      scanned = Hash.new(false)

      until heap.empty?
        u = heap.pop
        scanned[u] = true

        graph.adjacent_vertices(u).each do |v|
          unless scanned[v]
            new_distance = distance[u] + 1 # length(u, v)

            if new_distance <= distance[v]
              if new_distance < distance[v]
                heap.decrease_priority v, distance[v], new_distance
                distance[v] = new_distance
              end

              shortest_path_graph.add_edges DirectedEdge.new(u, v)
            end
          end
        end
      end

      return shortest_path_graph
    end # ::solve

    def self.shortest_paths shortest_path_graph, source, target
      stack = Array.new
      shortest_paths = Array.new

      shortest_path_graph.outgoing_edges(source).each do |edge|
        stack.push [edge]
      end

      until stack.empty?
        path = stack.pop

        if path.last.head == target
          shortest_paths << path
        else
          shortest_path_graph.outgoing_edges(path.last.head).each do |edge|
            stack.push(path.dup << edge)
          end
        end
      end

      shortest_paths.map! do |path|
        Path.new *path.map!(&:to_undirected_edge)
      end

      return shortest_paths
    end # ::shortest_paths
  end # Dijkstra

  class Graph
    def shortest_paths source, target
      Dijkstra.solve self, source
    end
  end # Graph

end # Rubi
