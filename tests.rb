require 'test/unit'
require 'pry'

class Graph
  def self.combinations paths, target_vertices
    valid_combinations = paths.combination(target_vertices.sort!.length - 1).select { |combination|
      combination.map(&:endpoints).flatten.uniq.sort == target_vertices
    }

    current_length = Float::INFINITY

    combinations = []

    valid_combinations.map { |combination|
      combination = combination.map(&:edges).flatten.uniq.sort

      if combination.length == current_length
        combinations << combination
      elsif combination.length < current_length
        current_length = combination.length
        combinations = [combination]
      end
    }

    combinations.uniq.sort
  end
end

class GraphElement
  def <=> element
    object_id <=> element.object_id
  end
end

class Vertex < GraphElement
  attr_reader :name

  def initialize name
    @name = name
  end
end

class Edge < GraphElement
  attr_reader :endpoints

  def initialize one_endpoint, another_endpoint
    @endpoints = [one_endpoint, another_endpoint].sort
  end
end

class Path
  attr_reader :endpoints, :edges

  def initialize *edges
    @edges = edges.sort
    
    hash = Hash.new(0)
    edges.map(&:endpoints).flatten.each { |vertex|
      hash[vertex] += 1
    }

    @endpoints = hash.select { |k,v| v == 1 }.keys.sort
  end

  def length
    @edges.length
  end
end

class TestCombination < Test::Unit::TestCase

  def setup
    @vertices = [@a = Vertex.new('A'),
                 @b = Vertex.new('B'),
                 @c = Vertex.new('C'),
                 @d = Vertex.new('D'),
                 @e = Vertex.new('E'),
                 @f = Vertex.new('F')]

    @ab = Edge.new @a, @b
    @ac = Edge.new @a, @c
    @bc = Edge.new @b, @c
    @bd = Edge.new @b, @d
    @be = Edge.new @b, @e
    @bf = Edge.new @b, @f
    @cd = Edge.new @c, @d
    @df = Edge.new @d, @f

    @target_vertices = [@a, @d, @e, @f]

    @paths = [Path.new(@ab, @be), Path.new(@ab, @bf), Path.new(@ab, @bd), Path.new(@ac, @cd),
              Path.new(@be, @bf), Path.new(@bd, @be), Path.new(@df)]
  end

  # def test_vertex
  #   assert_equal [@ab, @ac], @vertices.first.edges
  # end

  def test_path_length
    assert_equal 2, @paths.first.length
  end
  
  def test_path_endpoints
    assert_equal [@a, @e].sort, @paths.first.endpoints
  end

  def test_combinations
    assert_equal [[@ab, @bd, @be, @bf], [@ab, @be, @bf, @df], [@ab, @be, @bd, @df]].map(&:sort).sort, Graph.combinations(@paths, @target_vertices)
  end
end
