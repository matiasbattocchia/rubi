Main algorithm
--------------

1. Get shortest paths between target vertices of a connected graph.
2. Conform a complete graph of target vertices (nodes) and shortest paths (edges).
3. Find the minimum spanning trees of the complete graph.
4. Expand the minimum spanning trees into spanning tres of the original graph.

TODO
----

* Composite keys support
* SQLite, MySQL, SQL Server support

Test
----

http://linux.dell.com/dvdstore

1. Download and untar
  1. http://linux.dell.com/dvdstore/ds21.tar.gz
  2. http://linux.dell.com/dvdstore/ds21_postgresql.tar.gz

cd ds2/pgsqlds2/
sh pgsqlds2_create_all.sh
