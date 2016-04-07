require 'byebug'
class Route

  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def run(request, response)
    # Pattern is a regular expression object, so we can call match directly on it
    match_data = pattern.match(request.fullpath)
    # Params is the request params we are familiar with. This will get pass into
    # our controller
    params = {}
    match_data.names.each do | key, value |
      params[key.to_sym] = match_data[key]
    end
    request.params.each do | key, value |
      params[key.to_sym] = value
    end
    controller_class.new(request, response, params).invoke_action(action_name)
  end

  def matches?(request)
    (pattern =~ request.path) && (request.request_method == http_method.to_s.upcase)
  end

end
