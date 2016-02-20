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
end
