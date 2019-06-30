require 'net/http'
require 'json'
require "yaml"

def fetch_and_persist(uri, redirect_limit: 3)
  response = Net::HTTP.get_response(uri)

  case response
  when Net::HTTPSuccess then
    parsed = JSON.parse(response.body)
    data = extract(parsed)
    save(data)
    puts "Data persisted in fonts.yml file."
  when Net::HTTPRedirection then
    location = response.location
    puts "redirected to #{location}"
    fetch(location, redirect_limit - 1)
  else
    puts response.code
  end
end

def extract(data)
  variants_1 = 0
  variants_2 = 0

  foo = data['items'].map do |item|
    next unless item['kind'] == 'webfonts#webfont'
    variants = ['regular', 'italic']

    if variants.all? { |e| item['variants'].include?(e) } && item['variants'].size > 2
      variants_1 += 1
    else
      variants_2 += 1
      next
    end

    {
      'family' => item['family'],
      'category' => item['category'],
      'variants' => item['variants'],
      'source' => 'google_fonts'
    }
  end

  puts variants_1
  puts variants_2

  foo
end

def save(data)
  File.open("fonts.yml", 'w') do |f|
    f.write(YAML.dump(data))
  end
end

api_key = ENV['GOOGLE_WEBFONTS_API']
url = "https://www.googleapis.com/webfonts/v1/webfonts?key=#{api_key}"
uri = URI(url)

fetch_and_persist(uri)
