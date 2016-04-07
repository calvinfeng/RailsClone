require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'

class ControllerBase
  attr_reader :request, :response, :params

  def initialize(request, response, params = {})
    @request = request
    @response = response
    @params = params
  end

  def session
    @session ||= Session.new(request)
  end

  # This is to prevent user from rendering twice
  def already_built_response?
    @already_built_response ||= false
  end

  def invoke_action(action_name)
    self.send(action_name)
    unless already_built_response?
      render(action_name)
    end
  end

  def redirect_to(url)
    if already_built_response?
      raise Exception.new("Response has already been built")
    else
      @response['Location'] = url
      @response.status = 302  # performing redirection
      @already_built_response = true
      session.store_session(response)
    end
  end

  def render(template_name)
    if already_built_response?
      raise Exception.new("Response has already been built")
    else
      controller_name = self.class.to_s.underscore
      template = ERB.new(
        File.read("../views/#{controller_name}/#{template_name}.html.erb")
      )
      # Binding enables ERB to gain access to variables in this context,
      # notably, the instance variables we defined in the controller class
      render_content(template.result(binding), "text/html")
      session.store_session(response)
      @already_built_response = true
    end
  end

  def render_content(content, content_type)
    if already_built_response?
      raise Exception.new("Response has already been built")
    else
      @response['Content-Type'] = content_type
      @response.write(content)
      @response.finish
      @already_built_response = true
      session.store_session(response)
    end
  end

end
