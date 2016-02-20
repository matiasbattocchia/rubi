module Rubi
  module Algorithms
    def self.shortest_path_tree(graph, source_vertex)
      # https://github.com/monora/rgl/blob/master/lib/rgl/dijkstra.rb
      # http://en.wikipedia.org/wiki/Dijkstra's_algorithm
      #
      # The current implementation modifies the original Dijkstra's algorithm
      # to support parallel edges and to return every shortest path possible.
      #
      # Floyd-Warshall algorithm was considered as it finds shortest paths
      # between all pairs of vertices in a sigle run. Its O(|V|^3) complexity
      # does not provides better performance than running Dijkstra in
      # O(|E| + |V| log |V|) time for each possible source vertex when the
      # graph is sparse, as turns out to be the case of data warehouse schemas.

      distance = Hash.new(Float::INFINITY)
      distance[source_vertex] = 0

      queue = MinPriorityQueue.new

      graph.vertices.each { |vertex| queue.push(vertex, distance[vertex]) }

      scanned = {}
      parallel_edges = []

      until queue.empty?
        vertex = queue.pop

        scanned[vertex] = true

        graph.adjacent_vertices(vertex).each do |neighbour_vertex|
          next if scanned[neighbour_vertex]

          minimum_weight = Float::INFINITY

          graph.incident_edges(vertex, neighbour_vertex).each do |edge|
            weight = edge.properties[:weight] || 1

            if weight < minimum_weight
              parallel_edges.clear
              minimum_weight = weight
            end

            parallel_edges << edge if weight == minimum_weight
          end

          new_distance = distance[vertex] + minimum_weight

          if new_distance < distance[neighbour_vertex]
            queue.decrease_key(neighbour_vertex, new_distance)
            distance[neighbour_vertex] = new_distance
          end

          if new_distance == distance[neighbour_vertex]
            parallel_edges.each do |edge|
              # This is how the shortest-path tree information is stored in the
              # graph edges. The tree is used to reconstruct the shortest paths
              # between the source vertex and any other connected vertex.
              #
              # Edge object:
              #
              # @properties = {
              #   signs: {
              #     from_edge_vertex_A =>
              #       [to_source_vertex_1, to_source_vertex_2, ... ],
              #     from_edge_vertex_B =>
              #       [to_source_vertex_3, to_source_vertex_4, ... ] },
              #   other_prop: ... }

              edge.properties[:signs] ||=
                Hash.new { |hash, key| hash[key] = [] }

              edge.properties[:signs][neighbour_vertex] << source_vertex
            end
          end
        end
      end

      graph
    end

    def self.shortest_paths(graph, source_vertex, target_vertex)
      # Paths are reconstructed from target (a leaf) to source (the root).

      queue = []
      paths = []

      path = Path.new
      vertex = target_vertex

      loop do
        graph.incident_edges(vertex).each do |edge|
          next unless
            edge.properties[:signs] &&
            edge.properties[:signs].fetch(vertex, nil) &&
            edge.properties[:signs].fetch(vertex).include?(source_vertex)

          if edge.adjacent_vertex_of(vertex) == source_vertex
            paths
          else
            queue
          end << Path.new(edge, *path.edges)
        end

        break if queue.empty?

        path = queue.shift
        vertex = path.adjacent_vertex_of(target_vertex)
      end

      paths
    end

    def self.matroid(path_ground_set, target_vertices)
      # Recommended lecture:
      #
      # Matroids you have known by D. Nell and N. Neudauer;
      # Mathematics Magazine, vol. 82, no.1, February 2009.
      #
      # http://www.maa.org/sites/default/files/pdf/
      #   shortcourse/2011/matroidsknown.pdf

      minimum_weight = Float::INFINITY
      independent_sets = Set.new
      target_vertices = Set.new(target_vertices)
      rank = target_vertices.size - 1

      path_ground_set.combination(rank).each do |path_combination|
        next unless
          path_combination.map(&:endpoints).flatten.to_set == target_vertices
        # This could be the comparison of two arrays. I choose to compare
        # sets because I do not want to sort the arrays to compare them;
        # :sort relies on :<=> method, and since any object can be a vertex
        # this could be a problem as not all objects implement the
        # aforementioned method.

        # Following code executes if path_combination is an independet set.

        edge_set = path_combination.map(&:edges)
          .reduce(Set.new) { |p, q| p.union q }

        if edge_set.size < minimum_weight
          independent_sets.clear
          minimum_weight = edge_set.size
        end

        independent_sets << edge_set if edge_set.size == minimum_weight
      end

      independent_sets
    end

    def self.spanning_trees(graph, target_vertices)
      source_vertices = target_vertices.clone

      source_vertices.each do |source_vertex|
        next if graph.incident_edges(source_vertex).find do |edge|
               edge.properties[:signs] &&
               edge.properties[:signs].values.flatten.include?(source_vertex)
             end

        shortest_path_tree(graph, source_vertex)
      end

      paths = []

      source_vertices.each do |source_vertex|
        target_vertices.delete(source_vertex)

        target_vertices.each do |target_vertex|
          paths.concat(shortest_paths(graph, source_vertex, target_vertex))
        end
      end

      # This is unnecessary. It communicates better what's going on, though.
      target_vertices = source_vertices

      matroid(paths, target_vertices)
    end
  end
end
