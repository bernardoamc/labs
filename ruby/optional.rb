class Optional
  class << self
    def from_value(value)
      new(value)
    end
  end

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def and_then(&block)
    if value.nil?
      self.class.new(nil)
    else
      self.class.new(
        block.call(value)
      )
    end
  end

  def method_missing(method, *args, &block)
    and_then do |value|
      value.public_send(method, *args, &block)
    end
  end
end

Project = Struct.new(:creator)
Person  = Struct.new(:address)
Address = Struct.new(:country)
Country = Struct.new(:capital)
City    = Struct.new(:weather)

def weather_for_v1(project)
  Optional.from_value(project)
    .and_then { |project| project.creator }
    .and_then { |creator| creator.address }
    .and_then { |address| address.country }
    .and_then { |country| country.capital }
    .and_then { |capital| capital.weather }
    .value
end

def weather_for_v2(project)
  Optional.from_value(project)
    .creator
    .address
    .country
    .capital
    .weather
    .value
end

city = City.new('sunny')
country = Country.new(city)
address = Address.new(country)
person = Person.new(address)
project = Project.new(person)

puts 'V1:'
puts weather_for_v1(project)
puts weather_for_v1(nil)

puts '-' * 10
puts 'V2:'
puts weather_for_v2(project)
puts weather_for_v2(nil)
