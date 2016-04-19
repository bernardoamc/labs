# Consists in creating a method with a few other methods that can be overrided
# in specialized classes. These methods are called hook methods.
#
# Let's see an example:

class Server
  def initialize(request)
    @request = request
  end

  # Our template method with a series of hook methods.
  def response
    parse_request
    do_something
    put_response
  end

  def parse_request
    @request
  end

  def do_something
  end

  def put_response
    puts @request.join
  end
end

class SuperServer < Server
  def do_something
    puts "Super Server in action!"
  end
end

class AwesomeServer < Server
  def do_something
    puts "Awesome Server in action!"
    @request << [:status, 200]
  end

  def put_response
    puts "Logging response: #{@request}"
    super
  end
end

SuperServer.new(["params", "uri"]).response
AwesomeServer.new(["params", "uri"]).response
