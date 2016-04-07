require 'active_support/inflector'

class SQLObject

  extend Searchable
  extend Associatable

  def self.all
    parameters = DBConnection.execute(<<-SQL)
    SELECT *
    FROM #{self.table_name}
    SQL
    parse_all(parameters)
  end

  def self.parse_all(results)
    objects = []
    results.each do | result |
      objects << self.new(result)
    end
    objects
  end

  def self.find(id)
    self.all.each do | object |
      return object if object.id == id
    end
    nil
  end

  def self.columns
    if @columns.nil?
      query = DBConnection.execute2(<<-SQL)
        SELECT *
        FROM #{self.table_name}
      SQL
      @columns = query.first.map{ |col_name| col_name.to_sym }
    else
      @columns
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    if @table_name
      @table_name
    else
      self.to_s.tableize
    end
  end

  def self.finalize!
    self.columns.each do |column|
      # Create setter
      define_method("#{column}=") do |value|
        attributes[column] = value
      end

      # Create getter
      define_method(column) do
        attributes[column]
      end
    end
  end

  #=====================================================================
  # Instance methods

  def initialize(params = {})
    params.each do | attr_name, value |
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute #{attr_name}"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  # Insert instance of the SQL Object into the actual database
  def insert
    col_names = self.class.columns.drop(1).map{|col| col.to_s}.join(",")
    question_marks = attribute_values.map{|question_mark| "?"}.join(',')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name}(#{col_names})
      VALUES (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.drop(1)
                                  .map{|col| "#{col.to_s} = ?"}
                                  .join(",")
    object_id = attribute_values.first
    DBConnection.execute(<<-SQL, *attribute_values.drop(1), object_id)
      UPDATE #{self.class.table_name}
      SET #{col_names}
      WHERE id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

end
