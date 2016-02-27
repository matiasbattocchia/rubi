module Rubi
  class Database
    class Column
      attr_reader :name, :data_type, :constraint_types

      def initialize(column_table, column_name,
                     data_type, constraint_types = [])

        @table = table
        @name = name
        @data_type = data_type
        @constraint_types = constraint_types
      end

      def full_name
        @table.full_name + '.' + @name
      end
    end

    class Table
      attr_reader :name, :columns

      def initialize(table_schema, table_name, columns = [])
        @schema = table_schema
        @name = table_name
        @columns = columns
      end

      def full_name
        @schema + '.' + @name
      end

      def full_name_for_sequel
        (@schema + '__' + @name).to_sym
      end
    end

    class Relationship < DirectedEdge
      attr_reader :name, :pairs_of_columns

      def initialize(constraint_name, referencing_table,
                     referenced_table, pairs_of_columns = [])

        super referencing_table, referenced_table
        @name = constraint_name
        @pairs_of_columns = pairs_of_columns
      end

      def full_name
        referencing_table.full_name + '.' + @constraint_name
      end

      def join_conditions
        @pairs_of_columns.map do |pair_of_columns|
          pair_of_columns.map(&:full_name)
        end
      end

      alias referencing_table tail
      alias referenced_table  head
    end

    def initialize(options)
      @db = Sequel.connect(options)
      @graph = Graph.new

      @adapter =
        case options[:adapter]
        when 'postgres'
          PostgreSQL
        when 'mysql2'
          MySQL
        else
          raise "Adapter '#{options[:adapter]}' not supported."
        end

      load_tables
      load_relationships
    end

    def tables
      @graph.vertices
    end

    def relationships
      @graph.edges
    end

    private

    def load_tables
      columns = @db.fetch(@adapter::COLUMNS).all
      # table_schema,
      # table_name,
      # column_name,
      # data_type,
      # constraint_type

      # tables = @db.fetch(Tables).all
      tables = columns.map do |column|
        {table_schema: column[:table_schema],
         table_name:   column[:table_name]}
      end.uniq

      tables.each do |table|
        new_table = Table.new(table[:table_schema],
                              table[:table_name])

        table_columns = columns.select do |column|
          column[:table_schema] == table[:table_schema] &&
            column[:table_name] == table[:table_name]
        end

        table_columns.each do |column|
          new_column = Column.new(new_table,
                                  column[:column_name],
                                  column[:data_type].to_sym,
                                  column[:constraint_types])

          new_table.columns << new_column
        end

        @graph.add_vertex(new_table)
      end
    end

    def load_relationships
      # binding.pry
      relationships = @db.fetch(@adapter::RELATIONSHIPS).all
      # constraint_name,    | These three fields are
      # referencing_schema, | sufficient to identify
      # referencing_table,  | a relationship.
      # referencing_column,
      # referenced_schema,
      # referenced_table,
      # referenced_column

      unique_relationships = relationships.map do |relationship|
        {constraint_name:    relationship[:constraint_name],
         referencing_schema: relationship[:referencing_schema],
         referencing_table:  relationship[:referencing_table],
         referenced_schema:  relationship[:referenced_schema],
         referenced_table:   relationship[:referenced_table]}
      end.uniq

      unique_relationships.each do |unique_relationship|
        referencing_table = @graph.vertices.find do |table|
          table.schema == unique_relationship[:referencing_schema] &&
            table.name == unique_relationship[:referencing_table]
        end

        referenced_table = @graph.vertices.find do |table|
          table.schema == unique_relationship[:referenced_schema] &&
            table.name == unique_relationship[:referenced_table]
        end

        new_relationship = Relationship.new(
          unique_relationship[:constraint_name],
          referencing_table,
          referenced_table)

        pairs_of_columns = relationships.select do |relationship|
          relationship[:constraint_name]    ==
            unique_relationship[:constraint_name] &&
          relationship[:referencing_schema] ==
            unique_relationship[:referencing_schema] &&
          relationship[:referencing_table]  ==
            unique_relationship[:referencing_table]
        end

        pairs_of_columns.each do |pair_of_columns|
          referencing_column = referencing_table.columns.find do |column|
            column.name == pair_of_columns[:referencing_column]
          end

          referenced_column = referenced_table.columns.find do |column|
            column.name == pair_of_columns[:referenced_column]
          end

          new_relationship.pairs_of_columns << [referencing_column,
                                                referenced_column]
        end

        @graph.add_edge(new_relationship)
      end
    end
  end
end
