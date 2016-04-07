# Imagine we are in a Cat class
# cat belongs to human so we say,
# belongs_to human
# primary_key: :id
# foreign_key: :human_id
# class_name: "Human"
module Associatable

  def belongs_to(name, options = {})
    define_method(name) do
      options_obj = BelongsToOptions.new(name, options)
      f_key = self.send(options_obj.foreign_key)
      owner_class = options_obj.model_class
      owner_class.where(options_obj.primary_key => f_key).first
    end
    # When we call *name, for this case, it's *human, it returns a
    # human object from the last statement above: owner_class.where...
    @options = BelongsToOptions.new(name, options)
  end

  def has_many(name, options = {})
    define_method(name) do
      options_obj = HasManyOptions.new(name, self.class.to_s, options)
      p_key = self.send(options_obj.primary_key)
      child = options_obj.model_class
      child.where(options_obj.foreign_key => p_key)
    end
    @options = HasManyOptions.new(name, self.class.to_s, options)
  end

  def assoc_options
    if @options.nil?
      @assoc_options = {}
    else
      @assoc_options = {@options.class_name.downcase.to_sym => @options}
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      # instance scope
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key

      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key
      # through_object's foreign key is basically self id
      key_val = self.send(through_fk)
      results = DBConnection.execute(<<-SQL, key_val)
          SELECT
          #{source_table}.*
          FROM
          #{through_table}
          JOIN
          #{source_table}
          ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
          WHERE
          #{through_table}.#{through_pk} = ?
        SQL
      source_options.model_class.parse_all(results).first
    end
  end

end
