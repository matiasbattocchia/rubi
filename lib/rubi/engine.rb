module Rubi
  # def report *tables
  #   tables = @graph.vertices.select { |table|
  #     tables.include? table.name
  #   }

  #   sets = @graph.spanning_trees *tables

  #   sets.each do |set|
  #     joined_tables = [tables.first]
  #     dataset = @db[tables.first.fqn].select_all(*tables.map(&:fqn))

  #     set.each do |relationship|
  #       table = if joined_tables.include? relationship.referencing_table
  #                 relationship.referenced_table
  #               else
  #                 relationship.referencing_table
  #               end

  #       joined_tables << table

  #       dataset = dataset.join(table.fqn, relationship.conditions)
  #     end # inject
  #   end # each

  #   dataset
  # end

  # class Relationship < DirectedEdge
  #   attr_reader :name, :pairs_of_columns

  #   def initialize(constraint_name, referencing_table,
  #                  referenced_table, pairs_of_columns = [])

  #     super referencing_table, referenced_table
  #     @name = constraint_name
  #     @pairs_of_columns = pairs_of_columns
  #   end

  #   def full_name
  #     referencing_table.full_name + '.' + @name
  #   end

  #   def join_conditions
  #     @pairs_of_columns.map do |pair_of_columns|
  #       pair_of_columns.map(&:full_name)
  #     end
  #   end

  #   alias referencing_table tail
  #   alias referenced_table  head
  # end
end
