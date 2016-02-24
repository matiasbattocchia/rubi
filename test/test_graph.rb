require 'minitest/autorun'
require 'rubi'

include Rubi

describe Graph do
  let(:graph) do
    Graph.new(DirectedEdge.new(:a, :b), Edge.new(:b, :c))
  end

  describe '==' do
    it 'is equal' do
      same_graph = Graph.new(Edge.new(:b, :c), DirectedEdge.new(:a, :b))

      graph.must_equal same_graph
    end

    it 'is not equal' do
      different_graph = Graph.new(DirectedEdge.new(:b, :a), Edge.new(:b, :c))

      graph.wont_equal different_graph
    end
  end
end
