# postgreSQL
# In information_schema table schema the following tables seem useful:
#   (tables)
#   (columns)
#   table_constraints
#   key_column_usage
#   constraint_column_usage
#
# SELECT
#   tc.constraint_name, tc.table_name, kcu.column_name, 
#   ccu.table_name AS foreign_table_name,
#   ccu.column_name AS foreign_column_name 
# FROM 
#   information_schema.table_constraints AS tc 
#   JOIN information_schema.key_column_usage AS kcu
#     ON tc.constraint_name = kcu.constraint_name
#   JOIN information_schema.constraint_column_usage AS ccu
#     ON ccu.constraint_name = tc.constraint_name
#  WHERE constraint_type = 'FOREIGN KEY' AND tc.table_name='mytable';
#
# Source:
# http://stackoverflow.com/questions/1152260/postgres-sql-to-list-table-foreign-keys
#
# Note the the query will not work if composite keys are present in the schema.

require 'sequel'
require './graph'

module Rubi
  class Relationship < DirectedEdge
    attr_reader :referencing_column, :referenced_column
    
    def initialize referencing_schema, referencing_table, referencing_column,
                   referenced_schema,  referenced_table,  referenced_column

      super(referencing_schema + '.' + referencing_table,
            referenced_schema  + '.' + referenced_table)

      @referencing_column = referencing_column
      @referenced_column = referenced_column
    end

    alias referencing_table tail
    alias referenced_table  head
  end
  
  DB = Sequel.postgres(host: 'localhost', user: 'matias', database: 'warehouse')

  query = "SELECT
             kcu.table_schema AS referencing_schema,
             kcu.table_name AS referencing_table,
             kcu.column_name AS referencing_column,
             ccu.table_schema AS referenced_schema,
             ccu.table_name AS referenced_table,
             ccu.column_name AS referenced_column
           FROM 
             information_schema.table_constraints AS tc
             JOIN information_schema.key_column_usage AS kcu
               USING (constraint_schema, constraint_name)
             JOIN information_schema.constraint_column_usage AS ccu
               USING (constraint_schema, constraint_name)
           WHERE constraint_type = 'FOREIGN KEY'"

  graph = Graph.new
  
  DB.fetch query do |row|
    graph.add_edges Relationship.new(*row.values)
  end
end
