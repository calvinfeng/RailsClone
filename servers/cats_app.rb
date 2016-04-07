require_relative '../lib/resources'
require 'rack'

class Cat < SQLObject
  belongs_to :owner,
  primary_key: :id,
  foreign_key: :owner_id,
  class_name: 'Human'
end

class Human < SQLObject
  has_many :cats,
  primary_key: :id,
  foreign_key: :owner_id,
  class_name: 'Cat'
end

class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def show
    @cat = Cat.find(params[:id].to_i)
    render :show
  end

  def create
    @cat = Cat.new(params[:cat])
    @cat.save
    redirect_to("/cats")
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
end

cat_app = Proc.new do |env|
  request = Rack::Request.new(env)
  response = Rack::Response.new
  router.run(request, response)
  response.finish
end

Cat.finalize!
Cat.table_name
Cat.all

Rack::Server.start(
  app: cat_app,
  Port: 3000
)
