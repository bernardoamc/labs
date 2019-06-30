require_relative "minetest"

class JohnWick
  def dinner_reservation
    12
  end

  def personal?
    true
  end
end

class JohnWickTest < Minetest
  test '#dinner_reservation is always for twelve' do

  end

  test '#personal' do

  end
end

JohnWickTest.run
