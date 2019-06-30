require 'nokogiri'

FONT_STYLE = {
  'normal' => 'n',
  'italic' => 'i',
  'oblique' => 'o',
}.freeze

FONT_WEIGHT = {
  '100' => '1',
  '200' => '2',
  '300' => '3',
  '400' => '4',
  '500' => '5',
  '600' => '6',
  '700' => '7',
  '800' => '8',
  '900' => '9',
}.freeze

FONT_STRETCH = {
  'ultra-condensed' => 'a',
  'extra-condensed' => 'b',
  'condensed' => 'c',
  'semi-condensed' => 'd',
  'normal' => 'n',
  'semi-expanded' => 'e',
  'expanded' => 'f',
  'extra-expanded' => 'g',
  'ultra-expanded' => 'h',
}.freeze

def transform_to_fvd(attributes)
 "%s%s%s" % [FONT_STYLE.fetch(attributes[:style]), FONT_WEIGHT.fetch(attributes[:weight]), FONT_STRETCH.fetch(attributes[:stretch])]
end

xml_file = File.read('fontlist.xml')
doc = Nokogiri::XML.parse(xml_file)

doc.xpath('//font').each do |font|
  puts '-' * 100
  puts "#{font['displayName']}, TTF file: #{font['ttf']}"
  puts "Styles: weight #{font['FontWeight']}, style #{font['FontStyle']}, stretch #{font['FontStretch']}"
  puts "FVD: #{transform_to_fvd(weight: font['FontWeight'], style: font['FontStyle'], stretch: font['FontStretch'])}"
end
