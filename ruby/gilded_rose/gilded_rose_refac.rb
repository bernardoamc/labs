# Constraints:
#   1. Can't change Item class
#   2. Can't touch the @items property
#
#   Considerations:
#     1. This seems like a good problem for inheritance since sub-classes are specializations
#        and will use all of the parent methods.
#     2. Given that we can't change @items this is not possible unfortunately. Making me go for
#        composition with specialized quality updaters.
#     3. We could have updaters for sell_in and quantity separately.

class AgedBrieQualityUpdater
  MAXIMUM_QUALITY = 50
  APPRECIATION_STEP = 1

  def self.update(item)
    item.sell_in = item.sell_in - 1
    return item if item.quality >= MAXIMUM_QUALITY

    item.quality = if item.sell_in >= 0
      item.quality + APPRECIATION_STEP
    else
      item.quality + (2 * APPRECIATION_STEP)
    end

    item.quality = MAXIMUM_QUALITY if item.quality > MAXIMUM_QUALITY
    item
  end
end

class BackstagePassQualityUpdater
  MINIMUM_QUALITY = 0
  MAXIMUM_QUALITY = 50
  APPRECIATION_STEP = 1

  def self.update(item)
    item.sell_in = item.sell_in - 1
    return item if item.quality >= MAXIMUM_QUALITY

    item.quality = if item.sell_in < 0
      MINIMUM_QUALITY
    elsif item.sell_in <= 5
      item.quality + (3 * APPRECIATION_STEP)
    elsif item.sell_in <= 10
      item.quality + (2 * APPRECIATION_STEP)
    else
      item.quality + APPRECIATION_STEP
    end

    item.quality = MAXIMUM_QUALITY if item.quality > MAXIMUM_QUALITY
    item
  end
end

class SulfurasQualityUpdater
  def self.update(item)
    item
  end
end

class ConjuredQualityUpdater
  MINIMUM_QUALITY = 0
  DEPRECIATION_STEP = 2

  def self.update(item)
    item.sell_in = item.sell_in - 1
    return item if item.quality == MINIMUM_QUALITY

    item.quality = if item.sell_in >= 0
      item.quality - DEPRECIATION_STEP
    else
      item.quality - (2 * DEPRECIATION_STEP)
    end

    item.quality = MINIMUM_QUALITY if item.quality < MINIMUM_QUALITY
    item
  end
end

class NormalQualityUpdater
  MINIMUM_QUALITY = 0
  DEPRECIATION_STEP = 1

  def self.update(item)
    item.sell_in = item.sell_in - 1
    return item if item.quality == MINIMUM_QUALITY

    item.quality = if item.sell_in >= 0
      item.quality - DEPRECIATION_STEP
    else
      item.quality - (2 * DEPRECIATION_STEP)
    end

    item.quality = MINIMUM_QUALITY if item.quality < MINIMUM_QUALITY
    item
  end
end

class GildedRose
  def initialize(items)
    @items = items
  end

  def update_quality
    @items.map! do |item|
      case item.name
      when 'Aged Brie'
        AgedBrieQualityUpdater.update(item)
      when 'Backstage passes to a TAFKAL80ETC concert'
        BackstagePassQualityUpdater.update(item)
      when 'Sulfuras, Hand of Ragnaros'
        SulfurasQualityUpdater.update(item)
      when /Conjured/
        ConjuredQualityUpdater.update(item)
      else
        NormalQualityUpdater.update(item)
      end
    end
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
