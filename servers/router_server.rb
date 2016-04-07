require 'rack'
require_relative '../lib/resources'

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

class Cat
  attr_reader :name, :owner
  def initialize(name = "", owner = "")
    @name = name
    @owner = owner
  end
end

class CatsController < ControllerBase
  def index
    @cats = $cats
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
end

cat_app = Proc.new do |env|
  request = Rack::Request.new(env)
  response = Rack::Response.new
  router.run(request, response)
  response.finish
end

Rack::Server.start(
  app: cat_app,
  Port: 3000
)
