require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, params = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase,
      primary_key: :id
    }
    
    defaults.keys.each do |key|
      self.send("#{key}=", params[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, params = {})
    defaults = {
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id
    }
    
    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
    @assoc_params
  end
  
  def belongs_to(name, params = {})
    self.assoc_params[name] = BelongsToOptions.new(name, params)
    
    define_method(name) do
      params = self.class.assoc_params[name]
      
      key_val = self.send(params.foreign_key)
      params.model_class.where(params.primary_key: key_val).first
  end

  def has_many(name, params = {})
    self.assoc_params[name] = HasManyOptions.new(name, self.name, params)
    
    define_method(name) do
      params = self.class.assoc_params[name]
      
      key_val = self.send(params.primary_key)
      params.model_class.where(params.foreign_key: key_val)
    end
  end
  
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_params = self.class.assoc_params[through_name]
      source_params = through_params.model_class.assoc_params[source_name]
      
      through_table = through_params.table_name
      through_primary_key = through_params.primary_key
      through_foreign_key = throguh_params.foreign_key
      
      source_table = source_params.table_name
      source_primary_key = source_params.primary_key
      source_foreign_key = source_params.foreign_key
      
      key_val = self.send(through_foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
      SELECT #{source_table}.*
      FROM #{through_table}
      JOIN #{source_table}
      ON #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
      WHERE #{through_table}.#{through_primary_key} = ?
      SQL
      
      source_params.model_class.parse_all(results).first
    end
  end
end

class SQLObject
  extend Associatable
end
