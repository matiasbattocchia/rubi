require 'minitest/autorun'
require 'rubi/graph'
require 'rubi/algorithms'

class TestCombination < Test::Unit::TestCase
  # def setup
  #   vertices = [@a = 'A',
  #               @b = 'B',
  #               @c = 'C',
  #               @d = 'D',
  #               @e = 'E',
  #               @f = 'F']

  #   edges = [@ab = UndirectedEdge.new(@a, @b),
  #            @ac = UndirectedEdge.new(@a, @c),
  #            @bc = UndirectedEdge.new(@b, @c),
  #            @bd = UndirectedEdge.new(@b, @d),
  #            @be = UndirectedEdge.new(@b, @e),
  #            @bf = UndirectedEdge.new(@b, @f),
  #            @cd = UndirectedEdge.new(@c, @d),
  #            @df = UndirectedEdge.new(@d, @f)]

  #   @graph = Graph.new.add_edges *edges

  #   @target_vertices = [@a, @d, @e, @f]

  #   @paths = [Path.new(@ab, @be), Path.new(@ab, @bf), Path.new(@ab, @bd), Path.new(@ac, @cd),
  #             Path.new(@be, @bf), Path.new(@bd, @be), Path.new(@df)]
  # end

  # def test_vertex
  #   assert_equal [@ab, @ac], @vertices.first.edges
  # end

  def test_minimum_paths
    assert_equal [Path.new(@ab, @bd), Path.new(@ac, @cd)], Graph.minimum_paths(@edges, @a, @d)
  end

  # def test_all_minimum_paths
  #   assert_equal @paths, Graph.all_minimum_paths(@edges, @target_vertices)
  # end

  # def test_path_length
  #   assert_equal 2, @paths.first.length
  # end
  
  # def test_path_endpoints
  #   assert_equal [@a, @e].sort, @paths.first.endpoints
  # end

  # def test_combinations
  #   assert_equal [[@ab, @bd, @be, @bf], [@ab, @be, @bf, @df], [@ab, @be, @bd, @df]].map(&:sort).sort, Graph.combinations(@paths, @target_vertices)
  # end
end

