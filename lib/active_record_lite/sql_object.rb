require_relative 'db_connection'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |row_params| self.new(row_params) }
  end
end

class SQLObject < MassObject
  def attributes
    @attributes ||= {}
  end
  
  def self.columns
    @columns ||= begin
      cols = DBConnection.execute2("SELECT * FROM #{ self.table_name}")[0]
      cols.each do |name|
        define_method(name) do
          self.attributes[name]
        end
        define_method("#{name}") do |value|
          self.attributes[name] = value
        end
      end
      
      cols.map(&:to_sym)
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name.underscore.pluralize
  end

  def self.table_name
    @table_name
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{self.table_name}
    SQL
    parse_all(rows)
  end

  def self.find(id)
    rows = DBConnection.execute(<<-SQL, id)
    SELECT *
    FROM #{self.table_name}
    WHERE id = ?
    SQL
    
    row.nil? ? nil : self.new(row)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute: #{attr_name}"
      end
    end
  end

  def insert
    column_names = self.class.columns.map(&:to_s).join(", ")
    question_marks = (["?"] * self.class.columns.count).join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO #{self.class.table_name} (#{column_names})
    VALUES (#{question_marks})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def update
    attributes = self.class.attributes.map { |attribute| "#{attribute} = ?" }
    
    DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE #{self.class.table_name}
    SET #{attributes.join(", ")}
    WHERE id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  def attribute_values
    self.class.attributes.map { |attribute| send(attribute) }
  end
end
