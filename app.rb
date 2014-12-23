require 'bundler'
Bundler.require
require 'set'

# DB = Sequel.connect 'postgres://localhost/warehouse?user=matias'

# TODO: Inflecciones para los nombres de las tablas y columnas,
# de modo que si la tabla no ha sido especificada puede ser inferida
# del nombre de la clase.

# Para el join, la foreign key se infiere como el nombre de la tabla
# padre más el sufijo _id, mientras que se supone que la primary key
# es simplemente id.

class Graph
  attr_reader :vertices, :edges

  def initialize
    @vertices = Set.new
    @edges = Set.new
  end
end

class Vertex
  def initialize edges = nil, content = nil
    @edges = edges
    @content = content if content
  end
end

class Edge
  def initialize endpoints, content = nil
    @content = content if content
  end
end

#     def initialize
#       dist = {}
#       previous = {}
#       unvisited_nodes = Set.new
#       visited_nodes = Set.new
#       target_nodes = Set.new

#       unvisited_nodes << Node.new(@nodes.first, 0)

#       until unvisited_nodes.empty? || target_nodes.empty?
#         visited_nodes << node

#         node.to_const.neighbors.each do |neighbor|
#           unless visited_nodes.include? neighbor
#             alt = dist[node] + 1
#             if alt < dist[neighbor]
#               dist[neighbor] = alt
#               previous[neighbor] = node
#             end
#           end
#         end
#       end
#     end

# function Dijkstra(Graph, source):
#     dist[source]  := 0                     // Distance from source to source
#     for each vertex v in Graph:            // Initializations
#         if v ≠ source
#             dist[v]  := infinity           // Unknown distance function from source to v
#             previous[v]  := undefined      // Previous node in optimal path from source
#         end if 
#         add v to Q                         // All nodes initially in Q (unvisited nodes)
#     end for
#     
#     while Q is not empty:                  // The main loop
#         u := vertex in Q with min dist[u]  // Source node in first case
#         remove u from Q 
#         
#         for each neighbor v of u:           // where v has not yet been removed from Q.
#             alt := dist[u] + length(u, v)
#             if alt < dist[v]:               // A shorter path to v has been found
#                 dist[v]  := alt 
#                 previous[v]  := u 
#             end if
#         end for
#     end while
#     return dist[], previous[]
# end function

class Symbol
  def to_const
    Kernel.const_get self.to_s.split('_').map(&:capitalize).join
  end
end

module Rubi
  module Basic
    attr_reader :tables

    def table table
      @tables ||= Set.new
      @tables << table
    end
  end

  module Attribute
    include Basic

    attr_reader :parents, :children

    def neighbors; @parents + @children end

    def parent table
      @parents ||= Set.new
      @parents << table
    end

    def child table
      @children ||= Set.new
      @children << table
    end
  end

  module Fact
    include Basic

    attr_reader :fact

    def fact expression
      @fact = expression
    end
  end

  module Report
    def column attribute
      @nodes ||= Set.new
      @nodes << attribute
    end

    def metric metric
      @nodes ||= Set.new
      @nodes << metric
    end

    # def initialize
    #   @nodes.first
    # end
  end
end

class Año
  extend Rubi::Attribute
  
  table  :años
  child  :trimestre
end

class TrimestreDelAño
  extend Rubi::Attribute

  table  :trimestres_del_año
  child  :trimestre
end

class Trimestre
  extend Rubi::Attribute

  table  :trimestres
  parent :año
  parent :trimestre_del_año
  child  :cuenta
end

class Compañía
  extend Rubi::Attribute

  table  :compañías
  child  :cuenta
end

class CódigoNivel7
  extend Rubi::Attribute

  table  :códigos_nivel_7
  child  :código_nivel_8
end

class CódigoNivel8
  extend Rubi::Attribute

  table  :códigos_nivel_8
  parent :código_nivel_7
  child  :cuenta
end

# class Cuenta
#   extend Rubi::Attribute

#   table  :cuentas
#   parent :trimestre
#   parent :compañía
#   parent :código_nivel_8
# end

class ImporteTrimestral
  extend Rubi::Fact

  table :cuentas
  fact  'importe_trimestral * signo'
end

class Activo
  extend Rubi::Report

#   pageby TrimestreDelAño
#   pageby Compañía

  column :año
  column :código_nivel_7
  metric :importe_trimestral
end

g = Graph.new
s = Set.new

ObjectSpace.each_object(Rubi::Basic) do |object|
  object.tables.each do |table|
    s << table
  end
end

binding.pry

#insert into ZZT5VPGB1WMMQ000 
#selecta11.[CALL_CTR_ID] AS CALL_CTR_ID,
#CALL_CTR_IDa12.[YEAR_ID] AS YEAR_ID
#from[DAY_CTR_SLS]DAY_CTR_SLSa11, 
#DAY_CTR_SLSa11[LU_DAY]LU_DAYa12
#wherea11.[DAY_DATE] = a12.[DAY_DATE]
#group bya11.[CALL_CTR_ID],
#CALL_CTR_IDa12.[YEAR_ID]
#havingsum((a11.[TOT_DOLLAR_SALES] - a11.[TOT_COST])) > 100000.0

#selecteda12.[YEAR_ID] AS YEAR_ID,
#YEAR_IDa11.[CALL_CTR_ID] AS CALL_CTR_ID,
#CALL_CTR_IDmax(a14.[CENTER_NAME]) AS CENTER_NAME,
#CENTER_NAMEa14.[REGION_ID] AS REGION_ID,
#REGION_IDmax(a15.[REGION_NAME]) AS REGION_NAME0,
#REGION_NAME0sum((a11.[TOT_DOLLAR_SALES] - a11.[TOT_COST])) AS WJXBFS1
#from[DAY_CTR_SLS]DAY_CTR_SLSa11, 
#DAY_CTR_SLSa11[LU_DAY]LU_DAYa12, 
#LU_DAYa12[ZZT5VPGB1WMMQ000]ZZT5VPGB1WMMQ000pa13, 
#ZZT5VPGB1WMMQ000pa13[LU_CALL_CTR]LU_CALL_CTRa14, 
#LU_CALL_CTRa14[LU_REGION]LU_REGIONa15
#wherea11a11.[DAY_DATE] = a12.[DAY_DATE] and 
#anda11.[CALL_CTR_ID] = pa13.[CALL_CTR_ID] and 
#anda12.[YEAR_ID] = pa13.[YEAR_ID] and 
#anda11.[CALL_CTR_ID] = a14.[CALL_CTR_ID] and 
#anda14.[REGION_ID] = a15.[REGION_ID]
#group bya11a12.[YEAR_ID],
#YEAR_IDa11.[CALL_CTR_ID],
#CALL_CTR_IDa14.[REGION_ID]


# Activos(2012, 'Primero', 'Mapfre').all
