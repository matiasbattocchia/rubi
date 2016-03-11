module Rubi
  class Column
    attr_reader :table, :name, :full_name, :data_type

    def initialize(column_table, column_name, data_type)
      @table = column_table
      @name = column_name
      @full_name = column_table.full_name + '.' + column_name
      @data_type = data_type
    end
  end

  class Table
    attr_reader :name, :full_name, :sequel_name,
                :columns, :relationships

    def initialize(database_name, schema_name, table_name)
      @name = table_name
      @full_name = database_name + '.' + schema_name + '.' + table_name
      @sequel_name = (schema_name + '__' + table_name).to_sym
      @columns = []
      @relationships = []
    end

    def find_column(full_name)
      @columns.find { |column| column.full_name == full_name }
    end
  end

  class Relationship
    attr_reader :name, :full_name,
                :referencing_table, :referencing_columns,
                :referenced_table,  :referenced_columns

    def initialize(constraint_name,
                   referencing_table, referencing_columns,
                   referenced_table,  referenced_columns)

      # if referencing_columns.size != referenced_columns.size
      #   raise 'Quantity of referencing columns ' \
      #         'and referenced columns mismatch.'
      # end

      # if column = referencing_columns.find? { |c| c.table != referencing_table }
      #   raise "Column #{column.full_name} does not belong to " \
      #         "table #{referencing_table.full_name}."
      # end

      # if column = referenced_columns.find? { |c| c.table != referenced_table }
      #   raise "Column #{column.full_name} does not belong to " \
      #         "table #{referenced_table.full_name}."
      # end

      # if referencing_columns.map(&:data_type) !=
      #     referenced_columns.map(&:data_type)

      #   raise 'Column data type mismatch. Order matters: ' \
      #         'First referencing column compares its type ' \
      #         'with the first referenced\'s and so on.'
      # end

      @name      = constraint_name
      @full_name = referencing_table.full_name + '.' + constraint_name

      @referencing_table   = referencing_table
      @referencing_columns = referencing_columns.freeze
      @referenced_table    = referenced_table
      @referenced_columns  = referenced_columns.freeze
    end
  end

  class Database
    # Database objects are identifyied by
    # database.schema.table.column and
    # database.schema.table.constraint.
    #
    # MySQL objects will have database and schema
    # names duplicated, as it lacks schemas.
    attr_reader :tables, :relationships, :connection

    def initialize(options)
      @tables = []
      @relationships = []
      @connection = Sequel.connect(options)

      @adapter =
        case options[:adapter]
        when 'postgres'
          PostgreSQL
        when 'mysql2'
          MySQL
        else
          raise "Adapter '#{options[:adapter]}' not supported."
        end

      @name = options[:database]

      load_tables
      load_relationships
    end

    def find_table(full_name)
      @tables.find { |table| table.full_name == full_name }
    end

    def find_relationship(full_name)
      @relationships.find { |relationship| relationship.full_name == full_name }
    end

    private

    def load_tables
      columns = @connection.fetch(@adapter::COLUMNS).all
      # table_schema,
      # table_name,
      # column_name,
      # data_type,
      # constraint_types

      tables = columns.map do |column|
        {table_schema: column[:table_schema],
         table_name:   column[:table_name]}
      end.uniq

      tables.each do |table|
        new_table = Table.new(@name,
                              table[:table_schema],
                              table[:table_name])

        table_columns = columns.select do |column|
          column[:table_schema] == table[:table_schema] &&
            column[:table_name] == table[:table_name]
        end

        table_columns.each do |column|
          new_column = Column.new(new_table,
                                  column[:column_name],
                                  column[:data_type].to_sym)

          new_table.columns << new_column
        end

        @tables << new_table
      end
    end

    def load_relationships
      dot = '.'.freeze

      relationships = @connection.fetch(@adapter::RELATIONSHIPS).all
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

      unique_relationships.each do |unique|
        referencing_table = find_table(
          @name + dot +
          unique[:referencing_schema] + dot +
          unique[:referencing_table])

        referenced_table = find_table(
          @name + dot +
          unique[:referenced_schema] + dot +
          unique[:referenced_table])

        referencing_columns = []
        referenced_columns  = []

        pairs_of_columns = relationships.select do |relationship|
          relationship[:constraint_name]    ==
            unique[:constraint_name] &&
          relationship[:referencing_schema] ==
            unique[:referencing_schema] &&
          relationship[:referencing_table]  ==
            unique[:referencing_table]
        end

        pairs_of_columns.each do |pair_of_columns|
          referencing_columns << referencing_table.find_column(
            @name + dot +
            unique[:referencing_schema] + dot +
            unique[:referencing_table] + dot +
            pair_of_columns[:referencing_column])

          referenced_columns << referenced_table.find_column(
            @name + dot +
            unique[:referenced_schema] + dot +
            unique[:referenced_table] + dot +
            pair_of_columns[:referenced_column])
        end

        new_relationship = Relationship.new(
          unique[:constraint_name],
          referencing_table, referencing_columns,
          referenced_table, referenced_columns)

        @relationships << new_relationship
      end
    end
  end
end
