require 'minitest/autorun'
require 'rubi'
require 'pry'

include Rubi

db = DB.new(host: 'localhost', user: 'matias', database: 'warehouse')
# db.graph.to_shortest_path_graph('documentos')
