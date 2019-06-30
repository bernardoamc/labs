# NOTES
# - `type` doesn't have a default but some fields have a length validation without a `type`
# - Having `validations` return an array of hashes where the first key of the hash is the field name is a bit weird
# - We don't document the fact that the validation spec is in the response
# - Seems weird to return the spec on every page. Perhaps a different endpoint?
# - We don't document the `pagination` part of the response

require 'net/http'
require 'cgi'
require 'uri'
require 'json'

bind = -> (fn, *bound_args) {
  -> (*args) { fn.(*bound_args, *args) }
}

encode_query_string = -> (hash) {
  hash.map do |key, value|
    [key, value]
      .map { |part| CGI.escape(part.to_s) }
      .join('=')
  end.join('&')
}

BASE_URL = "http://127.0.0.1:3000/customers.json"

build_field_validator = -> (field, options) {
  -> (doc) {
    required = options.fetch('required', false)
    value = doc[field]

    break !required if value.nil?

    if options['type']
      case options['type']
      when 'string'
        break false unless value.is_a?(String)
      when 'number'
        break false unless value.is_a?(Numeric)
      when 'boolean'
        break false unless [true, false].include?(value)
      else
        raise "Invalid type: #{options['type']}"
      end
    end

    if options['length'].is_a?(Hash)
      min, max = options['length'].values_at('min', 'max')

      break false if min && value.length < min
      break false if max && value.length > max
    end

    true
  }
}

build_validators = -> (validations_json) {
  validators = {}
  validations_json.each do |validation_definitions|
    validation_definitions.each do |(field, options)|
      (validators[field] ||= []) << build_field_validator.(field, options)
    end
  end
  validators
}

combine_validators = -> (validators) {
  -> (doc) {
    validators.reject do |field, field_validators|
      field_validators.all? { |v| v.(doc) }
    end.keys
  }
}

fetch_customers = -> (page) {
  target = URI(BASE_URL)
  target.query = encode_query_string.(page: page)
  response_json = JSON.parse(Net::HTTP.get(target))
  [response_json, bind.(fetch_customers, page + 1)]
}

validator_cache = Hash.new do |hash, key|
  hash[key] = combine_validators.(build_validators.(key))
end

validate_customers = -> () {
  errors = []
  response, fetch_next = fetch_customers.(1)

  until response['customers'].empty?
    validate = validator_cache[response['validations']]

    response['customers'].each do |customer|
      invalid_fields = validate.(customer)
      unless invalid_fields.empty?
        errors << { "id" => customer["id"], "invalid_fields" => invalid_fields }
      end
    end

    response, fetch_next = fetch_next.()
  end

  errors
}

puts JSON.pretty_generate(validate_customers.())
