require 'minitest/autorun'
require 'rubi'

include Rubi

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
  @shortest_path_graph ||= Graph.new UndirectedEdge.new(:a, :b),
                                     UndirectedEdge.new(:a, :c),
                                     UndirectedEdge.new(:b, :d),
                                     UndirectedEdge.new(:b, :e),
                                     UndirectedEdge.new(:b, :f),
                                     UndirectedEdge.new(:c, :d)
end

def spanning_trees
  @spanning_trees ||= Set.new [Set.new([UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :d),
                                 UndirectedEdge.new(:b, :e), UndirectedEdge.new(:b, :f)]),
                               Set.new([UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :e),
                                 UndirectedEdge.new(:b, :f), UndirectedEdge.new(:d, :f)]),
                               Set.new([UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :e),
                                 UndirectedEdge.new(:b, :d), UndirectedEdge.new(:d, :f)])]
end

describe ShortestPathGraph do

  describe '::new' do
    it 'returns a shortest path graph for source' do
      ShortestPathGraph.new(graph, :a).must_equal shortest_path_graph
    end
  end

  describe '#shortest_paths' do
    it 'returns shortest paths for source and target' do
      shortest_paths = [Path.new(UndirectedEdge.new(:a, :c)                            ),
                        Path.new(UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :d)),
                        Path.new(UndirectedEdge.new(:a, :c), UndirectedEdge.new(:c, :d))]

      ShortestPathGraph.new(graph, :a).shortest_paths(:c, :d).must_equal shortest_paths
    end
  end
end

describe Matroid do
  describe '::solve' do
    it 'returns all the independent spanning trees involving target vertices' do
      shortest_paths = [Path.new(UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :d)),
                        Path.new(UndirectedEdge.new(:a, :c), UndirectedEdge.new(:c, :d)),
                        Path.new(UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :e)),
                        Path.new(UndirectedEdge.new(:a, :b), UndirectedEdge.new(:b, :f)),
                        Path.new(UndirectedEdge.new(:e, :b), UndirectedEdge.new(:b, :f)),
                        Path.new(UndirectedEdge.new(:d, :b), UndirectedEdge.new(:b, :e)),
                        Path.new(UndirectedEdge.new(:d, :f))]

      Matroid.solve(shortest_paths, [:a, :d, :e, :f]).must_equal spanning_trees
    end
  end
end

describe Graph do
  describe '#spanning_trees' do
    it 'returns spanning trees' do
      graph.spanning_trees(:a, :d, :e, :f).must_equal spanning_trees
    end
  end
end
