require 'sqlite3'

# creating the database
# drop songs to avoid error
DB = {:conn => SQLite3::Database.new("db/songs.db")}
DB[:conn].execute("DROP TABLE IF EXISTS songs")

# creating the songs table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)

# method says: when a SELECT statment is executed, don't return
# a database row as an array, return it as a hash w/ 
# the column names as key
DB[:conn].results_as_hash = true
