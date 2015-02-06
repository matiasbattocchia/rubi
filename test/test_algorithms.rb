require 'minitest/autorun'
require 'rubi/graph'
require 'rubi/algorithms'
require 'pry'
include Rubi

describe Dijkstra do
  def graph
    @graph ||= Graph.new UndirectedEdge.new(:a, :b),
                         UndirectedEdge.new(:a, :c),
                         UndirectedEdge.new(:b, :c),
                         UndirectedEdge.new(:b, :d),
                         UndirectedEdge.new(:b, :e),
                         UndirectedEdge.new(:b, :f),
                         UndirectedEdge.new(:c, :d),
                         UndirectedEdge.new(:d, :f)
  end

  def shortest_path_graph
    @shortest_path_graph ||= Graph.new DirectedEdge.new(:a, :b),
                                       DirectedEdge.new(:a, :c),
                                       DirectedEdge.new(:b, :d),
                                       DirectedEdge.new(:b, :e),
                                       DirectedEdge.new(:b, :f),
                                       DirectedEdge.new(:c, :d)
  end

  describe '::solve' do
    it 'returns a shortest path graph for source' do
      Dijkstra.solve(graph, :a).must_equal shortest_path_graph
    end
  end

  describe '::build_paths' do
    it 'returns shortest paths for source and target' do
      shortest_paths = [Path.new(UndirectedEdge.new(:a, :c), UndirectedEdge.new(:c, :d)),
                        Path.new(UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :d))]

      Dijkstra.shortest_paths(shortest_path_graph, :a, :d).must_equal shortest_paths
    end
  end
end

# class TestCombination < Test::Unit::TestCase



#   #   @target_vertices = [@a, @d, @e, @f]

#   #   @paths = [Path.new(@ab, @be), Path.new(@ab, @bf), Path.new(@ab, @bd), Path.new(@ac, @cd),
#   #             Path.new(@be, @bf), Path.new(@bd, @be), Path.new(@df)]
#   # end

#   # def test_vertex
#   #   assert_equal [@ab, @ac], @vertices.first.edges
#   # end

#   def test_minimum_paths
#     assert_equal [Path.new(@ab, @bd), Path.new(@ac, @cd)], Graph.minimum_paths(@edges, @a, @d)
#   end

#   # def test_all_minimum_paths
#   #   assert_equal @paths, Graph.all_minimum_paths(@edges, @target_vertices)
#   # end

#   # def test_path_length
#   #   assert_equal 2, @paths.first.length
#   # end
  
#   # def test_path_endpoints
#   #   assert_equal [@a, @e].sort, @paths.first.endpoints
#   # end

#   # def test_combinations
#   #   assert_equal [[@ab, @bd, @be, @bf], [@ab, @be, @bf, @df], [@ab, @be, @bd, @df]].map(&:sort).sort, Graph.combinations(@paths, @target_vertices)
#   # end
# end

