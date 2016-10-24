module Rubi
  class Fact
  end

  class Metric
  end

  class Attribute
  end

  class Relationship
  end

  class Hierachy
  end

  class Report
  end

  class Universe
    def initialize(elements)
      @graph = Graph.new

      @graph.lock
      @elements = elements.each do |element|


        if element.has_key?('attribute')
          Attribute.new(element)
        elsif element.has_key?('fact')
          Fact.new(element)
        else
          raise 'Unknown element type.'
        end
      end
    end
  end
end
