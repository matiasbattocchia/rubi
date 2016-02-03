require 'minitest/autorun'
require 'rubi'
require 'pry'

include Rubi

# hash = {host: 'localhost', user: 'matias', database: 'warehouse'}

db = DB.new(host: 'localhost', user: 'matias', database: 'warehouse')

db.report('documentos', 'trimestres', 'coberturas')

# spg = db.graph.to_shortest_path_graph('documentos')

# spg.shortest_paths('trimestres')

# db.graph.spanning_trees('documentos', 'trimestres')
