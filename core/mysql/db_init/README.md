# db_init

Files with extensions `.sh`, `.sql` and `.sql.gz` in this directory will be 
automatically executed the first time the container is started. Files are 
executed in alphabetical order.

Any special initializations can then be included here.

By default, this folder contains the following files:

* 0050_create_arrowhead_database_empty.sql
* 0050_create_log_db_empty.sql

The numbers at the start of the file allow execution order control. The files 
above are not inter-dependent and therefore we do not care which runs first.
