require 'algorithms'

class MinPriorityQueue < Containers::Heap
  def initialize
    super { |a, b| a.distance < b.distance }
  end

  def push vertex, distance
    super vertex_key(vertex, distance), vertex
  end

  def decrease_priority vertex, old_distance, new_distance
    change_key vertex_key(vertex, old_distance), vertex_key(vertex, new_distance)
  end

  private

  def vertex_key vertex, distance
    VertexKey.new vertex, distance
  end

  VertexKey = Struct.new :vertex, :distance
end # MinPriorityQueue
