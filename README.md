Main algorithm
--------------

1. Get shortest paths between target vertices of a connected graph.
2. Conform a complete graph of target vertices (nodes) and shortest paths (edges).
3. Find the minimum spanning trees of the complete graph.
4. Expand the minimum spanning trees into spanning trees of the original graph.

TODO
----

- [x] PostgreSQL composite keys support.
- [ ] MySQL, SQL Server support.
- [ ] Test multiple constraints between the same pair of tables.

- [ ] Query optimization with EXPLAIN SQL command.
- [ ] Caching.
- [ ] Remember table/column OIDs.

Change constraint_type strings for symbols.

Test database
-------------

http://linux.dell.com/dvdstore

1. Download and untar
  1. http://linux.dell.com/dvdstore/ds21.tar.gz
  2. http://linux.dell.com/dvdstore/ds21_postgresql.tar.gz
2. cd ds2/pgsqlds2/
3. sh pgsqlds2_create_all.sh

Next goal
---------

Report revenue by product and category.
