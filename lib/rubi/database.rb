# PostgreSQL
#
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
# Note the query will not work if composite keys are present in the schema.

module Rubi

  module Queries
    module PostgreSQL

      Relationships =
        "SELECT
           key_column_usage.table_schema AS referencing_schema,
           key_column_usage.table_name AS referencing_table,
           key_column_usage.column_name AS referencing_column,
           constraint_column_usage.table_schema AS referenced_schema,
           constraint_column_usage.table_name AS referenced_table,
           constraint_column_usage.column_name AS referenced_column
         FROM
           information_schema.table_constraints
         JOIN
           information_schema.key_column_usage
         USING
           (constraint_schema, constraint_name)
         JOIN
           information_schema.constraint_column_usage
         USING
           (constraint_schema, constraint_name)
         WHERE
           constraint_column_usage.table_schema NOT IN ('information_schema', 'pg_catalog') AND
           table_constraints.constraint_type = 'FOREIGN KEY'"

      Columns =
        "SELECT
           columns.table_schema,
           columns.table_name,
           columns.column_name,
           columns.data_type,
           table_constraints.constraint_type
         FROM
           information_schema.columns
         LEFT JOIN
           information_schema.key_column_usage
         USING
           (table_name, column_name)
         LEFT JOIN
           information_schema.table_constraints
         USING
           (table_name, constraint_name)
         WHERE
           columns.table_schema NOT IN ('information_schema', 'pg_catalog')"

      Tables =
        "SELECT
           tables.table_schema,
           tables.table_name
         FROM
           information_schema.tables
         WHERE
           tables.table_schema NOT IN ('information_schema', 'pg_catalog')"

    end
  end

  class Relationship < DirectedEdge
    attr_reader :referencing_column, :referenced_column

    def initialize referencing_schema, referencing_table, referencing_column,
                   referenced_schema,  referenced_table,  referenced_column

      # super(referencing_schema + '.' + referencing_table,
      #       referenced_schema  + '.' + referenced_table)

      super(referencing_table, referenced_table)

      @referencing_column = referencing_table + '.' + referencing_column
      @referenced_column  = referenced_table  + '.' + referenced_column
    end

    alias referencing_table tail
    alias referenced_table  head
  end

  class DB
    Table = Struct.new :schema, :name
    Column = Struct.new :sce

    include Queries::PostgreSQL

    attr_reader :graph

    # PostgreSQL: Server > Database > Schema > SQL objects.
    # SQL Server is similar; MySQL lacks schemas.

    def initialize hash
      @connection = Sequel.postgres(hash)

      @graph = Graph.new

      columns = @connection.fetch(Columns).all
      tables = columns.map { |row| {table_schema: row[:table_schema], table_name: row[:table_name]} }.uniq

      tables.each do |table|
        columns.select { |column| column[:table_schema] == table[:table_schema] && column[:table_name] == table[:table_name] }
        @graph.add_vertices Table.new(*table.values)
      end

      @connection.fetch QUERY do |row|
        @graph.add_edges Relationship.new(*row.values)
      end
    end

    def report *tables
      sets = @graph.spanning_trees *tables

      sets.each do |set|

        queries = []
        joined_tables = []

        query = 'SELECT ' + tables.map { |table| table + '.*' }.join(', ') + ' FROM '

        set.each do |relation|
           query << if joined_tables.empty?
             joined_tables.concat relation.endpoints

             relation.referencing_table + "\n" +
             'JOIN ' + relation.referenced_table +
               ' ON ' + relation.referencing_column + ' = ' + relation.referenced_column + "\n"
           else
             if joined_tables.include? relation.referencing_table
               joined_tables << relation.referenced_table

               'JOIN ' + relation.referenced_table +
                 ' ON ' + relation.referencing_column + ' = ' + relation.referenced_column + "\n"
             else
               joined_tables << relation.referencing_table

               'JOIN ' + relation.referencing_table +
                 ' ON ' + relation.referencing_column + ' = ' + relation.referenced_column + "\n"
             end
           end
        end

        puts query

        queries << query
      end

      queries
    end
  end
end
