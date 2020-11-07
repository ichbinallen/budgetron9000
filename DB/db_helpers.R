########## DB Connections ##########
# DB WRITE con
.db_admin = new.env()
.db_admin$conlist = list(
  drv = RPostgres::Postgres(),
  dbname = "dbname",
  host = "host_name",
  port = 5432, 
  user = "admin_user", 
  password = "wrong_password"
)
.db_admin$get_con = function() {
  con = do.call(DBI::dbConnect, .db_admin$conlist)
  return(con)
}

# DB READ con
.db_read = new.env()
.db_read$conlist = list(
  drv = RPostgres::Postgres(),
  dbname = "dbname",
  host = "host_name",
  port = 5432, 
  user = "db_read", 
  password = "wrong_password"
)
.db_read$get_con = function() {
  con = do.call(DBI::dbConnect, .db_read$conlist)
  return(con)
}

########## Database helper functions ##########
# read_xxx = function(con, table_name) {
#   # validate table name
#   out = DBI::dbReadTable(con, table_name)
#   return(out)
# }
