require 'minitest/autorun'
require 'rubi'

include Rubi

def graph
  # A slightly modified bull graph (there is
  # an extra edge between b and d).
  #
  # https://en.wikipedia.org/wiki/Bull_graph
  #
  #    a           e
  #     \         /
  #      \       /
  #       b === d
  #        \   /
  #         \ /
  #          c

  Graph.new(Edge.new(:a, :b),
            Edge.new(:b, :c),
            Edge.new(:b, :d, {id: 'superior'}),
            Edge.new(:b, :d, {id: 'inferior'}),
            Edge.new(:c, :d),
            Edge.new(:d, :e))
end

def edges
  [Edge.new(:a, :b, {signs: {:b => [:a], :a => [:c, :d]} }),
   Edge.new(:b, :c, {signs: {:c => [:a], :b => [:c]} }),

   Edge.new(:b, :d, {id: 'superior',
                     signs: {:d => [:a], :b => [:d]} }),

   Edge.new(:b, :d, {id: 'inferior',
                     signs: {:d => [:a], :b => [:d]} }),

   Edge.new(:c, :d, {signs: {:d => [:c], :c => [:d]} }),
   Edge.new(:d, :e, {signs: {:e => [:a, :c, :d]} })]
end

def graph_with_trees
  Graph.new(*edges)
end

def paths
  [Path.new(edges[0], edges[1]),
   Path.new(edges[0], edges[2]),
   Path.new(edges[0], edges[3]),
   Path.new(edges[4])]
end

def spanning_trees
  Set.new([
    Set.new([edges[0], edges[1], edges[2]]),
    Set.new([edges[0], edges[1], edges[3]]),
    Set.new([edges[0], edges[1], edges[4]]),
    Set.new([edges[0], edges[2], edges[4]]),
    Set.new([edges[0], edges[3], edges[4]])
  ])
end

describe Algorithms do
  describe 'shortest_path_tree' do
    it 'generates the shortest-path tree for a given source vertex' do
      g = graph
      Algorithms.shortest_path_tree(g, :a)
      Algorithms.shortest_path_tree(g, :c)
      Algorithms.shortest_path_tree(g, :d)

      # must_equal fails, assert_equal kinda works, interchanging
      # actual and expected values. Strange...
      assert_equal(g, graph_with_trees)
    end
  end

  describe 'shortest_paths' do
    it 'returns shortest paths for source and target' do
      p = []
      p.concat(Algorithms.shortest_paths(graph_with_trees, :a, :c))
      p.concat(Algorithms.shortest_paths(graph_with_trees, :a, :d))
      p.concat(Algorithms.shortest_paths(graph_with_trees, :c, :d))

      p.must_equal(paths)
    end
  end

  describe 'matroid' do
    it 'returns all the independent spanning trees involving target vertices' do
      Algorithms.matroid(paths, [:a, :c, :d]).must_equal(spanning_trees)
    end
  end

  describe 'spanning_trees' do
    it 'returns spanning trees' do
      Algorithms.spanning_trees(graph, [:a, :c, :d]).must_equal(spanning_trees)
    end
  end
end
