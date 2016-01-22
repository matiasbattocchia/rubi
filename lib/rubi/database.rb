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

  class DB
    class Relationship < ::DirectedEdge

      # def initialize referencing_column, referenced_column
      #   super referencing_column, referenced_column
      # end

      def endpoints
        @endpoints.map &:table
      end

      alias referencing_column tail
      alias referenced_column  head

      def referencing_table; referencing_column.table end
      def referenced_table;  referenced_column.table  end
    end

    Table = Struct.new :schema, :name, :columns
    Column = Struct.new :table, :name, :data_type, :constraint_type

    include Queries::PostgreSQL

    attr_reader :graph

    # PostgreSQL: Server > Database > Schema > SQL objects.
    # SQL Server is similar; MySQL lacks schemas.

    def initialize hash
      @connection = Sequel.postgres hash

      @graph = Graph.new

      columns = @connection.fetch(Columns).all

      #tables = @connection.fetch(Tables).all
      tables = columns.map { |column| {table_schema: column[:table_schema], table_name: column[:table_name]} }.uniq

      tables.each do |table|
        new_table = Table.new *table.values, []

        table_columns = columns.select { |column|
          column[:table_schema] == table[:table_schema] && column[:table_name] == table[:table_name] }

        table_columns.each do |column|
          new_column = Column.new new_table, *column.values.slice(1..-1)
          new_table.columns << new_column
        end

        @graph.add_vertices new_table
      end

      @connection.fetch Relationships do |relationship|
        # referencing_schema, referencing_table, referencing_column
        referencing_table = @graph.vertices.find { |table|
          table.schema == relationship.referencing_schema &&
            table.name == relationship.referencing_table
        }

        referencing_column = referencing_table.columns.find { |column|
          column.name == relationship.referencing_column
        }

        # referenced_schema,  referenced_table,  referenced_column
        referenced_table = @graph.vertices.find { |table|
          table.schema == relationship.referenced_schema &&
            table.name == relationship.referenced_table
        }

        referenced_column = referenced_table.columns.find { |column|
          column.name == relationship.referenced_column
        }

        new_relationship = Relationship.new referencing_column, referenced_column

        @graph.add_edges new_relationship
      end
    end

    def report *tables
      sets = @graph.spanning_trees *tables

      sets.each do |set|

        queries = []
        joined_tables = []

        query = 'SELECT ' + tables.map { |table| table + '.*' }.join(', ') + ' FROM '

        set.each do |relationship|
           query << if joined_tables.empty?
             joined_tables.concat relationship.endpoints

             relationship.referencing_table + "\n" +
             'JOIN ' + relationship.referenced_table +
               ' ON ' + relationship.referencing_column + ' = ' + relationship.referenced_column + "\n"
           else
             if joined_tables.include? relationship.referencing_table
               joined_tables << relationship.referenced_table

               'JOIN ' + relationship.referenced_table +
                 ' ON ' + relationship.referencing_column + ' = ' + relationship.referenced_column + "\n"
             else
               joined_tables << relationship.referencing_table

               'JOIN ' + relationship.referencing_table +
                 ' ON ' + relationship.referencing_column + ' = ' + relationship.referenced_column + "\n"
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
