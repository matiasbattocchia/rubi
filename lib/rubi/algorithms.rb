require 'algorithms'

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
    def initialize graph, source, target
      # function Dijkstra(Graph, source):
      #     dist[source] := 0                     // Initializations
      #     for each vertex v in Graph:           
      #         if v ≠ source
      #             dist[v] := infinity           // Unknown distance from source to v
      #             prev[v] := undefined          // Predecessor of v
      #         end if
      #         Q.add_with_priority(v,dist[v])
      #     end for 


      #     while Q is not empty:                 // The main loop
      #         u := Q.extract_min()              // Remove and return best vertex
      #         mark u as scanned
      #         for each neighbor v of u:
      #             if v is not yet scanned:
      #                 alt = dist[u] + length(u, v) 
      #                 if alt < dist[v]
      #                     dist[v] := alt
      #                     prev[v] := u
      #                     Q.decrease_priority(v,alt)
      #                 end if
      #             end if
      #         end for
      #     end while
      #     return prev[]
    end
  end # Dijkstra

  class Graph
    def shortest_paths source, target
      Dijkstra.new self, source, target
    end
  end # Graph
end # Rubi
