require 'rack'

class Beginware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "before beginware"
    response = @app.call(env)
    puts "after beginware"
    response
  end
end

class Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "before middleware"
    response = @app.call(env)
    puts "after middleware"
    response
  end
end

class Endware
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "before endware"
    response = @app.call(env)
    puts "after endware"
    response
  end
end

class App
  def call(env)
    puts "before app"
    ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']]
  end
end


app = Rack::Builder.new do
  use Beginware
  use Middleware
  use Endware
  run App.new
end

run app
