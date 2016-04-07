require 'byebug'
class Router

  attr_reader :routes

  def run(request, response)
    matched_route = self.match(request)
    if matched_route
      matched_route.run(request, response)
    else
      response.status = 404
    end
  end

  def match(request)
    @routes.each do | route |
      if route.matches?(request)
        return route
      end
    end
    return nil
  end

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # Takes in a block, converted into proc, but instance_eval asks for a block,
  # so we pass it ampersand to convert the proc back into block.
  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do | http_method |
    define_method(http_method.to_s) do | pattern, controller_class, action_name |
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

end
