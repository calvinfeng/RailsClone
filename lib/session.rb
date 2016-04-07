require 'json'

class Session
  # Find the cookie for this application
  # Deserialize the cookie into a hash
  APP_NAME = "_rails_lite_app"

  def initialize(request)
    if request.cookies[APP_NAME]
      @cookie = JSON.parse(request.cookies[APP_NAME])
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, value)
    @cookie[key] = value
  end

  # Rack provides helper method for setting cookies and their attributes
  # Rack even provides a way for us to access the json data in cookies
  def store_session(response)
    attributes = { path: "/", value: @cookie.to_json }
    response.set_cookie(APP_NAME, attributes)
  end

end
