module Searchable

  def where(params)
    values = params.values
    attributes = params.keys.map{|key| "#{key} = ?"}.join(" AND ")
    query = DBConnection.execute(<<-SQL, *values)
              SELECT
                *
              FROM
                #{self.table_name}
              WHERE
                #{attributes}
            SQL

    if query.nil?
      nil
    else
      objects = []
      query.each do |param|
        objects << self.new(param)
      end
      objects
    end
  end

end
