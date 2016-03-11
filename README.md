# Ruby business intelligence

The built-in SQL backend of the framework provides ROLAP functionality on top a relational database.
Rubi contains a SQL query generator that translates the reporting queries into SQL statements.
The query generator takes into account topology of the schema and executes only joins
that are necessary to retrieve attributes required by the data analyst.

The SQL backend uses Sequel toolkit to construct the queries.

## Main algorithm

1. Get shortest paths between target vertices of a connected graph.
2. Conform a complete graph of target vertices (nodes) and shortest paths (edges).
3. Find the minimum spanning trees of the complete graph.
4. Expand the minimum spanning trees into spanning trees of the original graph.

## Database support

- [x] PostgreSQL
- [x] MySQL
- [ ] SQL Server

## Test database

http://linux.dell.com/dvdstore

1. Download and untar:
  1. http://linux.dell.com/dvdstore/ds21.tar.gz
  2. http://linux.dell.com/dvdstore/ds21_postgresql.tar.gz
  3. http://linux.dell.com/dvdstore/ds21_mysql.tar.gz
  4. http://linux.dell.com/dvdstore/ds21_sqlserver.tar.gz
2. Change to a specific database folder.
3. Run the create all script.

## Advanced features

- [x] Attribute roles
- [x] Multiple data sources
- [x] Aggregation awareness
- [ ] Data marts
- [ ] Fact level extensions (degrade/extend/disallow)
- [ ] Transformations
- [ ] Partitioning

## TODO

- [ ] Query optimization with EXPLAIN SQL command
- [ ] Caching
- [ ] Auto-reload files

- [ ] Export capabilities
- [ ] Security; user administration
