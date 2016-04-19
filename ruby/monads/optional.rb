Project = Struct.new(:creator)
Person  = Struct.new(:address)
Address = Struct.new(:country)
Country = Struct.new(:capital)
City    = Struct.new(:weather)

class Optional
  def self.from_value(value)
    new(value)
  end

  attr_reader :value
  def initialize(value)
    @value = value
  end

  def and_then(&block)
    if value.nil?
      Optional.new(nil)
    else
      block.call(value)
    end
  end

  def method_missing(*args, &block)
    and_then do |value|
      Optional.from_value(value.public_send(*args, &block))
    end
  end
end

def weather_for(project)
  Optional.from_value(project).
    creator.address.country.capital.weather.
    value
end

city = City.new('sunny')
country = Country.new(city)
address = Address.new(country)
person = Person.new(address)
project = Project.new(person)

puts weather_for(project)
puts weather_for(nil)
