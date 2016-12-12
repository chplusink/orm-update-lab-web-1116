require 'pry'
require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name,grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (id, name, grade)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql_id)[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = '#{self.name}', grade = '#{self.grade}' WHERE id = #{self.id}
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name,grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    student = Student.new(row[1],row[2])
    student.id = row[0]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    Student.new_from_db(DB[:conn].execute(sql,name)[0])
  end

end
