require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    param_keys = params.keys.map { |key| "#{key} = ?"}.join(" AND ")
    
    results = DBConnection.execute(<<-SQL, *params.values)
    SELECT *
    FROM #{self.table_name}
    WHERE #{param_keys}
    SQL
    
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
