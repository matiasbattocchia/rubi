module Rubi
  class Matroid
    # Recommended lecture:
    # Matroids you have known - D. Nell, N. Neudauer - Mathematics Magazine, vol. 82, no.1, February 2009.

    def self.solve path_ground_set, target_vertices
      minimum_weight = Float::INFINITY
      independent_sets = Set.new
      target_vertices = Set.new target_vertices
      rank = target_vertices.length - 1

      path_ground_set.combination(rank).each do |path_combination|
        if path_combination.map(&:endpoints).flatten.to_set == target_vertices
          # This could be the comparison of two arrays. I chose to compare sets because
          # I do not want to sort the arrays to compare them; :sort relies on :<=>
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
  end # Matroid

  class Graph
    def spanning_trees *target_vertices

      # Make shortest paths graphs for every target vertex but the last.
      shortest_path_graphs = target_vertices.slice(0...-1).map do |vertex|
        to_shortest_path_graph vertex
      end

      shortest_paths = Array.new

      shortest_path_graphs.each_with_index do |shortest_path_graph, index|
        # Get shortest paths between a target vertex (as source vertex) and subsequent
        # target vertices.
        shortest_paths.concat(
          shortest_path_graph.shortest_paths *target_vertices.slice( (index + 1)..-1 )
        )
      end

      Matroid.solve shortest_paths, target_vertices
    end # #spanning_trees
  end # Graph
end # Rubi
