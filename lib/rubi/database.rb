module Rubi

  module Queries
    module PostgreSQL

      Relationships =
        "SELECT
           constraints.constraint_name,
           referencing_schemas.nspname AS referencing_schema,
           referencing_tables.relname  AS referencing_table,
           referencing_columns.attname AS referencing_column,
           referenced_schemas.nspname  AS referenced_schema,
           referenced_tables.relname   AS referenced_table,
           referenced_columns.attname  AS referenced_column
         FROM (SELECT
                 conname   AS constraint_name,
                 conrelid  AS referencing_table_oid,
                 unnest(conkey)  AS referencing_column_number,
                 confrelid AS referenced_table_oid,
                 unnest(confkey) AS referenced_column_number
               FROM
                 pg_catalog.pg_constraint
               WHERE
                 contype = 'f') constraints
        JOIN
          pg_catalog.pg_class referencing_tables
          ON referencing_tables.oid = constraints.referencing_table_oid
        JOIN
          pg_catalog.pg_class referenced_tables
          ON referenced_tables.oid  = constraints.referenced_table_oid
        JOIN
          pg_catalog.pg_namespace referencing_schemas
          ON referencing_schemas.oid = referencing_tables.relnamespace
        JOIN
          pg_catalog.pg_namespace referenced_schemas
          ON referenced_schemas.oid  = referenced_tables.relnamespace
        JOIN
          pg_catalog.pg_attribute referencing_columns
          ON referencing_columns.attrelid = constraints.referencing_table_oid
          AND referencing_columns.attnum  = constraints.referencing_column_number
        JOIN
          pg_catalog.pg_attribute referenced_columns
          ON referenced_columns.attrelid = constraints.referenced_table_oid
          AND referenced_columns.attnum  = constraints.referenced_column_number
        WHERE
          referencing_schemas.nspname NOT IN ('information_schema', 'pg_catalog')"

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

      # Tables =
      #   "SELECT
      #      tables.table_schema,
      #      tables.table_name
      #    FROM
      #      information_schema.tables
      #    WHERE
      #      tables.table_schema NOT IN ('information_schema', 'pg_catalog')"

    end
  end

  class SQL
  end

  class DB
    class Relationship < DirectedEdge
      attr_reader :columns

      def initialize referencing_table, referenced_table
        super referencing_table, referenced_table

        @columns = []
      end

      def add_columns referencing_column, referenced_column
        @columns << [referencing_column, referenced_column]
      end

      def conditions
        @columns.map do |pair|
          pair.map do |column|
            column.table.fqn2 + '.' + column.name
          end
        end
      end

      alias referencing_table tail
      alias referenced_table  head
    end

    class Table
      attr_reader :schema, :name, :columns

      def initialize schema, name, columns = []
        @schema, @name, @columns = schema, name, columns
      end

      def fqn
        (@schema + '__' + @name).to_sym
      end

      def fqn2
        @schema + '.' + @name
      end
    end

    Column = Struct.new :table, :name, :data_type, :constraint_type

    include Queries::PostgreSQL

    attr_reader :graph

    # PostgreSQL: Server > Database > Schema > SQL objects.
    # SQL Server is similar; MySQL lacks schemas.

    def initialize hash
      @db = Sequel.postgres hash

      @graph = Graph.new

      columns = @db.fetch(Columns).all
        # table_schema,
        # table_name,
        # column_name,
        # data_type,
        # constraint_type

      #tables = @db.fetch(Tables).all
      tables = columns.map { |column| {table_schema: column[:table_schema], table_name: column[:table_name]} }.uniq

      tables.each do |table|
        new_table = Table.new table[:table_schema], table[:table_name]

        table_columns = columns.select { |column|
          column[:table_schema] == table[:table_schema] && column[:table_name] == table[:table_name] }

        table_columns.each do |column|
          new_column = Column.new new_table, column[:column_name], column[:data_type], column[:constraint_type]
          new_table.columns << new_column
        end

        @graph.add_vertices new_table
      end

      relationships = @db.fetch(Relationships).all
        # constraint_name,    | These three fields are
        # referencing_schema, | sufficient to identify
        # referencing_table,  | a relationship.
        # referencing_column,
        # referenced_schema,
        # referenced_table,
        # referenced_column

      unique_relationships = relationships.map { |relationship|
        {constraint_name: relationship[:constraint_name],
         referencing_schema: relationship[:referencing_schema],
         referencing_table: relationship[:referencing_table],
         referenced_schema: relationship[:referenced_schema],
         referenced_table: relationship[:referenced_table]} }.uniq

      unique_relationships.each do |unique_relationship|

        referencing_table = @graph.vertices.find { |table|
          table.schema == unique_relationship[:referencing_schema] &&
            table.name == unique_relationship[:referencing_table]
        }

        referenced_table = @graph.vertices.find { |table|
          table.schema == unique_relationship[:referenced_schema] &&
            table.name == unique_relationship[:referenced_table]
        }

        new_relationship = Relationship.new referencing_table, referenced_table

        pairs_of_columns = relationships.select { |relationship|
          relationship[:constraint_name]    == unique_relationship[:constraint_name] &&
          relationship[:referencing_schema] == unique_relationship[:referencing_schema] &&
          relationship[:referencing_table]  == unique_relationship[:referencing_table] }

        pairs_of_columns.each do |pair|
          referencing_column = referencing_table.columns.find { |column|
            column.name == pair[:referencing_column]
          }

          referenced_column = referenced_table.columns.find { |column|
            column.name == pair[:referenced_column]
          }

          new_relationship.add_columns referencing_column, referenced_column
        end

        @graph.add_edges new_relationship
      end
    end

    def report *tables
      tables = @graph.vertices.select { |table|
        tables.include? table.name
      }

      sets = @graph.spanning_trees *tables

      sets.each do |set|
        joined_tables = [tables.first]
        dataset = @db[tables.first.fqn].select_all(*tables.map(&:fqn))

        set.each do |relationship|
          table = if joined_tables.include? relationship.referencing_table
                    relationship.referenced_table
                  else
                    relationship.referencing_table
                  end

          joined_tables << table

          dataset = dataset.join(table.fqn, relationship.conditions)
        end # inject
      end # each

      dataset
    end
  end
end
