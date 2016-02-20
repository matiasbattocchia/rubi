# Ruby business intelligence

The built-in SQL backend of the framework provides ROLAP functionality on top a relational database. Rubi contains a SQL query generator that translates the reporting queries into SQL statements. The query generator takes into account topology of the schema and executes only joins that are necessary to retrieve attributes required by the data analyst.

The SQL backend uses Sequel toolkit to construct the queries.

Main algorithm
--------------

1. Get shortest paths between target vertices of a connected graph.
2. Conform a complete graph of target vertices (nodes) and shortest paths (edges).
3. Find the minimum spanning trees of the complete graph.
4. Expand the minimum spanning trees into spanning trees of the original graph.

TODO
----

- [x] PostgreSQL composite keys support.
- [ ] MySQL support.
- [ ] SQL Server support.

- [ ] Query optimization with EXPLAIN SQL command.
- [ ] Caching.
- [ ] Remember table/column OIDs.
- [ ] Auto-reload files.

- [ ] Export capabilities.
- [ ] Security; user administration.

Test database
-------------

http://linux.dell.com/dvdstore

1. Download and untar
  1. http://linux.dell.com/dvdstore/ds21.tar.gz
  2. http://linux.dell.com/dvdstore/ds21_postgresql.tar.gz
2. cd ds2/pgsqlds2/
3. sh pgsqlds2_create_all.sh
