# The Adapter pattern exists to connect different interfaces.
#
# For example, suppose your application have to communicate with
# a few different databases and every one of them has a different
# API, how would you manage that? This is the problem that this
# pattern tris to solve by generating a common API.
#
# Let's see an example:

class Database
  def select(connection, query)
    connection.select(query)
  end
end

class MysqlConnection
  def run_selection(query)
    puts query
  end
end

class PostgresConnection
  def select_query(query)
    puts query
  end
end

# We can't use the classes above since their API is different.

class MysqlConnectionAdapter
  def initialize(mysql_connection)
    @mysql_connection = mysql_connection
  end

  def select(query)
    @mysql_connection.run_selection(query)
  end
end

class PostgresConnectionAdapter
  def initialize(postgres_connection)
    @postgres_connection = postgres_connection
  end

  def select(query)
    @postgres_connection.select_query(query)
  end
end

db = Database.new
mysql_adapter = MysqlConnectionAdapter.new(MysqlConnection.new)
pg_adapter = PostgresConnectionAdapter.new(PostgresConnection.new)

db.select(mysql_adapter, "foo")
db.select(pg_adapter, "bar")
