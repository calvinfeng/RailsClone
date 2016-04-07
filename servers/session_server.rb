require 'rack'
require_relative '../lib/controller_base'

class MyController < ControllerBase
  def run
    session["count"] ||= 0
    session["count"] += 1
    render :counting_show
  end
end

# app must be able to receive call, hence we make it a proc
request_counting_app = Proc.new do |env|
  request = Rack:: Request.new(env)
  response = Rack::Response.new
  MyController.new(request, response).run
  response.finish
end

# Rack will start a server for us, as soon as we run this file
Rack::Server.start(
  app: request_counting_app,
  Port: 3000
)
