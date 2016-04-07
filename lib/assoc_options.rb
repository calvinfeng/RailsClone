# A simple class that will hold information we need to create table
# associations.

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end

end

class BelongsToOptions < AssocOptions
  # name represents the name of the owner object
  def initialize(name, options = {})
    default_options = {
      primary_key: :id,
      foreign_key: (name.to_s + "_id").to_sym,
      class_name: name.to_s.camelcase
    }
    default_options.keys.each do |key|
      self.send("#{key}=", options[key] || default_options[key])
    end
  end

end

class HasManyOptions < AssocOptions
  # name represents the name of the child object
  def initialize(name, self_class_name, options = {})
    default_options = {
       primary_key: :id,
       foreign_key: (self_class_name.to_s.underscore + "_id").to_sym,
       class_name: name.to_s.camelcase.singularize
    }
    default_options.keys.each do |key|
      self.send("#{key}=", options[key] || default_options[key])
    end
  end

end
