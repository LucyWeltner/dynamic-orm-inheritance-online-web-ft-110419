require_relative "../config/environment.rb"
require "pry"
#require 'active_support/inflector'

class InteractiveRecord

  def initialize(hash)
    self.class.column_names.each do |name|
      if hash[name.to_sym] && name != "id"
        self.send("#{name}=", hash[name.to_sym])
      elsif name == "id"
        self.send("#{name}=", nil)
      end
    end
  end


  def self.table_name
    self.to_s.downcase+"s"
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{self.table_name}')"
    table_as_hash = DB[:conn].execute(sql)
    column_names = table_as_hash.map{|attr| attr["name"]}
    column_names.compact
  end

  def self.col_names_for_insert
    self.column_names.delete_if{|name| name == "id"}.join(", ")
  end 

  def values_for_insert
    string = ""
    self.class.column_names.each do |name|
      if self.send(name) != nil
        string = string + self.send(name).to_s + ", "
      end
    end 
    string[0..-3]
  end

  def save 
    sql = "INSERT INTO #{self.class.table_name} (#{self.class.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    puts sql
    binding.pry
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}").flatten[0]
  end 

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
end 

































#   def self.table_name
#     self.to_s.downcase.pluralize
#   end

#   def self.column_names
#     DB[:conn].results_as_hash = true

#     sql = "pragma table_info('#{table_name}')"

#     table_info = DB[:conn].execute(sql)
#     column_names = []
#     table_info.each do |row|
#       column_names << row["name"]
#     end
#     column_names.compact
#   end

#   def initialize(options={})
#     options.each do |property, value|
#       self.send("#{property}=", value)
#     end
#   end

#   def save
#     sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
#     DB[:conn].execute(sql)
#     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
#   end

#   def table_name_for_insert
#     self.class.table_name
#   end

#   def values_for_insert
#     values = []
#     self.class.column_names.each do |col_name|
#       values << "'#{send(col_name)}'" unless send(col_name).nil?
#     end
#     values.join(", ")
#   end

#   def col_names_for_insert
#     self.class.column_names.delete_if {|col| col == "id"}.join(", ")
#   end

# def self.find_by_name(name)
#   sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
#   DB[:conn].execute(sql, name)
# end


