module Rubi
  module MySQL
    RELATIONSHIPS =
      "SELECT
         constraint_name,
         table_schema AS referencing_schema,
         table_name   AS referencing_table,
         column_name  AS referencing_column,
         referenced_table_schema AS referenced_schema,
         referenced_table_name   AS referenced_table,
         referenced_column_name  AS referenced_column
       FROM
         information_schema.key_column_usage
       WHERE
         referenced_table_name IS NOT NULL"
      .freeze

    COLUMNS =
      "SELECT
         columns.table_schema,
         columns.table_name,
         columns.column_name,
         columns.data_type,
         group_concat(table_constraints.constraint_type SEPARATOR ', ')
           AS constraint_types
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
         columns.table_schema <> 'information_schema'
       GROUP BY
         table_schema,
         table_name,
         column_name"
      .freeze
  end
end
