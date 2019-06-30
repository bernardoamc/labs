class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title, :price_code

  def initialize(title, the_price_code)
    @title, self.price_code = title, the_price_code
  end

  def price_code=(value)
    @price_code = value
    @price = case price_code
      when REGULAR: RegularPrice.new
      when NEW_RELEASE: NewReleasePrice.new
      when CHILDRENS: ChildrensPrice.new
    end
  end

  def charge(days_rented)
    @price.charge(days_rented)
  end

  def frequent_renter_points(days_rented)
    @price.frequent_renter_points(days_rented)
  end
end

class RegularPrice
  def charge(days_rented)
    result = 2
    result += (days_rented - 2) * 1.5 if days_rented > 2
    result
  end

  def frequent_renter_points(days_rented)
    1
  end
end

class NewReleasePrice
  def charge
    days_rented * 3
  end

  def frequent_renter_points(days_rented)
    if days_rented > 1
      2
    else
      1
    end
  end
end

class ChildrensPrice
  def charge(days_rented(
    result = 1.5
    result += (days_rented - 3) * 1.5 if days_rented > 3
    result
  end

  def frequent_renter_points(days_rented)
    1
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie, @days_rented = movie, days_rented
  end

  def charge
    movie.charge(days_rented)
  end

  def frequent_renter_points
    movie.frequent_renter_points(days_rented)
  end
end

class Customer
  attr_reader :name

  def initialize(name)
    @name = name
    @rentals = []
  end

  def add_rental(arg)
    @rentals << arg
  end

  def statement
    result = "Rental Record for #{@name}\n"

    @rentals.each do |element|
      # show figures for this rental
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
    end

    # add footer lines
    result += "Amount owed is #{total_charge}\n"
    result += "You earned #{total_frequent_renter_points} frequent renter points"
    result
  end

  def html_statement
    result = "<h1>Rentals for <em>#{@name}</em></h1><p>\n"

    @rentals.each do |element|
      # show figures for this rental
      result += "\t" + each.movie.title + ": " + element.charge.to_s + "<br>\n"
    end

    # add footer lines
    result += "<p>You owe <em>#{total_charge}</em><p>\n"
    result += "On this rental you earned " +
           "<em>#{total_frequent_renter_points}</em> " +
           "frequent renter points<p>"
    result
  end

  def total_charge
    @rentals.inject(0) { |sum, rental| sum + rental.charge }
  end

  def total_frequent_renter_points
    @rentals.inject(0) { |sum, rental| sum + rental.frequent_renter_points }
  end
end
