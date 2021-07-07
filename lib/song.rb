require_relative "../config/environment.rb"
require 'active_support/inflector'
class Song

# this method grabs us the table name
  def self.table_name
    # takes class name, turns to string, downcases string 
    # plurarize with #plurarize method
    self.to_s.downcase.pluralize
  end

  # this method grabs us the column names
  # querying = means a request for information
  def self.column_names
    DB[:conn].results_as_hash = true
# line below: will return to us an array of hashes
# describing the table itself.
# each has will contain info about one column
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    # iterate over the resulting array of hashes
    # to collect just the name of each column
    table_info.each do |row|
      column_names << row["name"]
    end
    # .compact gets rid of any nil values
    column_names.compact
  end
# create attr_accessors for our Song class
# we are telling our class that it should have an attr_accessor
# named after each column name
# iterate over the column names, convert the name string into symbol
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

# method takes in an argument of options, defaults to an empty hash
# .new to be called with a hash
  def initialize(options={})
    # will implicitly names arguments
    # iterate over options hash
    # use .send to interpolate the name of each hash key
    # as a method that we set ewual to that key's value
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  # instance of the class, not the class itself
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # this method gives us the table name 
  # associated to any given class
  def table_name_for_insert
    # we need this line in order to use
    # a class method inside an instance method
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end





