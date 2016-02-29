module Rubi
  module PostgreSQL
    RELATIONSHIPS =
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
      .freeze

    COLUMNS =
      "SELECT
         columns.table_schema,
         columns.table_name,
         columns.column_name,
         min(columns.data_type) AS data_type,
         string_agg(table_constraints.constraint_type, ', ') AS constraint_types
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
         columns.table_schema NOT IN ('information_schema', 'pg_catalog')
       GROUP BY
         columns.table_schema,
         columns.table_name,
         columns.column_name"
      .freeze

    # TABLES =
    #   "SELECT
    #      tables.table_schema,
    #      tables.table_name
    #    FROM
    #      information_schema.tables
    #    WHERE
    #      tables.table_schema NOT IN ('information_schema', 'pg_catalog')"
    #   .freeze
  end
end
