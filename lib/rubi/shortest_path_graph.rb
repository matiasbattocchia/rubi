module Rubi
  class ShortestPathGraph < Graph
    attr_reader :source_vertex

    def initialize graph, source_vertex
      @source_vertex = source_vertex
      super *dijkstra(graph)
    end

    def shortest_paths *target_vertices
      queue = Array.new
      scanned = Hash.new
      shortest_paths = Array.new

      incident_edges(@source_vertex).each do |edge|
        queue.push Path.new(edge)
        scanned[edge] = true
      end

      # This is to stop the search before it is useless.
      max_depth = target_vertices.map{ |vertex| @distance[vertex] }.max

      until queue.empty?
        path = queue.shift

        last_endpoint = path.adjacent_vertex_of @source_vertex

        if target_vertices.include? last_endpoint
          shortest_paths << path
        end

        incident_edges(last_endpoint).each do |edge|
          if !scanned[edge] &&
            @distance[edge.adjacent_vertex_of last_endpoint] <= max_depth

            # There is a kind of path duplication going on here.
            queue.push Path.new(*path.edges, edge)
            scanned[edge] = true
          end
        end
      end

      return shortest_paths
    end # ::shortest_paths

    private

    def dijkstra graph
      # https://github.com/monora/rgl/blob/master/lib/rgl/dijkstra.rb
      # http://en.wikipedia.org/wiki/Dijkstra's_algorithm
      #
      # The current implementation modifies the original algorithm
      # to support parallel edges and to return every shortest path possible.

      @distance = Hash.new(Float::INFINITY)
      @distance[@source_vertex] = 0

      queue = MinPriorityQueue.new

      graph.vertices.each do |vertex|
        queue.push vertex, @distance[vertex]
      end

      scanned = Hash.new
      edges = Array.new

      until queue.empty?
        vertex = queue.pop

        scanned[vertex] = true

        graph.adjacent_vertices(vertex).each do |neighbour_vertex|
          unless scanned[neighbour_vertex]
            parallel_edges = Array.new
            minimum_weight = Float::INFINITY

            graph.incident_edges(vertex, neighbour_vertex).each do |parallel_edge|
              if parallel_edge.weight < minimum_weight
                minimum_weight = parallel_edge.weight
                parallel_edges.clear << parallel_edge
              elsif parallel_edge.weight == minimum_weight
                parallel_edges << parallel_edge
              end
            end

            new_distance = @distance[vertex] + minimum_weight

            if new_distance < @distance[neighbour_vertex]
              queue.decrease_key neighbour_vertex, new_distance
              @distance[neighbour_vertex] = new_distance

              edges.concat parallel_edges
            elsif new_distance == @distance[neighbour_vertex]
              edges.concat parallel_edges
            end
          end # unless scanned[vertex]
        end # graph.adjacent_vertices
      end # until queue.empty?

      return edges
    end # #dijkstra
  end # ShortestPathGraph


  class Graph
    def to_shortest_path_graph source_vertex
      ShortestPathGraph.new self, source_vertex
    end
  end # Graph

end # Rubi
