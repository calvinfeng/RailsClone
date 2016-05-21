# RailsClone (MVC Web Framework)
This is a stripped down version of Rails and ActiveRecord. It utilizes Rack as web server interface. It takes http request through Rack::Request objects. It has its own router and routes that take http requests to appropriate controllers and render corresponding views. In order to use this piece of software, users will need to write controllers that inherit from ControllerBase class and write embedded ruby html files in the views folder. Controllers are responsible for constructing http responses while the ERB files are responsible for rendering the responses to viewers.

## Models
***Just like ActiveRecord***
This web framework uses SQLite3 for its simplicity and lightweightness, the whole database is on a file. The setup for SQLite3 is quick, minimize headaches.

Begin initializing a SQL file, for example, the `cats.sql` file. The SQLite3 ruby gem will take care of the rest.

In the `DBConnection` class,
``` ruby
def self.open(db_file_name)
  @db = SQLite3::Database.new(db_file_name)
  @db.results_as_hash = true
  @db.type_translation = true
  @db
end
```
SQLite3 gem provides a very convenient way to initialize database. It also provides access to execute SQL queries.

The SQLObject class contains the core logic of object-relational mapping. For example, the well-known `.all`, `.find`, `.create`, `.save` ActiveRecord methods are implemented here.

``` ruby
def self.all
  parameters = DBConnection.execute(<<-SQL)
  SELECT *
  FROM #{self.table_name}
  SQL
  parse_all(parameters)
end
```
The key `self` refers to the object itself. Say I have a cats table, the relational mapped object here is `Cat < SQLObject`. `Cat` class will inherit these handy methods from `SQLObject` class such that `Cat.all` will return all cats in Ruby object format.

Associations are also implemented. `has_many` and `belongs_to` can be found in `Associatable.rb`. Without going too much in depth, the association methods are simply SQL query on joining `foreign_key` to `primary_key`.

## Views
Every HTTP request will receive a response. The response is a HTML file. In the `ControllerBase` class, `render` and `render_content` are responsible for delivering this final response. `render` will construct an appropriate response from templates and instance variables while 'render_content' will write the result to HTML format and deliver it through `Rack::Response` object.

Ruby has a ERB gem and it will parse erb file into raw HTML. However, one needs to bind
the current context (local/instance variables) to the ERB template in order to get values of variables render in raw HTML
``` ruby
controller_name = self.class.to_s.underscore
template = ERB.new(
File.read("../views/#{controller_name}/#{template_name}.html.erb")
)
render_content(template.result(binding), "text/html")
```

## Controllers
Users will write custom controllers that inherit from `ControllerBase`. `ControllerBase` is there to provide the basic functionality on rendering a view. The key logic that made controller functional is the router. The router recognizes HTTP request methods such as `POST`, `GET`, `DELETE`, and `PATCH`. It channels the request to the appropriate controller. This is known as routing.

``` ruby
[:get, :post, :put, :delete].each do | http_method |
  define_method(http_method.to_s) do | pattern, controller_class, action_name |
    add_route(pattern, http_method, controller_class, action_name)
  end
end
```
There are four routes. `define_method` is a method that creates method, aka meta-programming.
These routes are customizable. Users will need to "draw" the routes so that router will recognize the intents of the web application

``` ruby
router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
end
```
An use case is illustrated in the example above: Users define get/post, the regular expression needed to match url pattern, and also the appropriate controller for the requests. ***Just like Rails!***

## Missing Feature
* Flash cookie
* CSRF Protection
