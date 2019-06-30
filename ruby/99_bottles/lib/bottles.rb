class Bottles
  def song
    verses(99, 0)
  end

  def verses(starts_with, ends_with)
    starts_with.downto(ends_with).map do |bottle_number|
      verse(bottle_number)
    end.join("\n")
  end

  def verse(number)
    case number
    when 0
      <<-VERSE.gsub(/^[\s\t]*/, '')
        No more bottles of beer on the wall, no more bottles of beer.
        Go to the store and buy some more, 99 bottles of beer on the wall.
      VERSE
    when 1
      <<-VERSE.gsub(/^[\s\t]*/, '')
        1 bottle of beer on the wall, 1 bottle of beer.
        Take it down and pass it around, no more bottles of beer on the wall.
      VERSE
    when 2
      <<-VERSE.gsub(/^[\s\t]*/, '')
        2 bottles of beer on the wall, 2 bottles of beer.
        Take one down and pass it around, 1 bottle of beer on the wall.
      VERSE
    else
      <<-VERSE.gsub(/^[\s\t]*/, '')
        #{number} bottles of beer on the wall, #{number} bottles of beer.
        Take one down and pass it around, #{number-1} bottles of beer on the wall.
      VERSE
    end
  end
end
