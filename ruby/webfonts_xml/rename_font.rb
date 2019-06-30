# This script does the following:
#
# 1- Reads a fontlist.xml in the directory and aggregate the fonts metadata
#    based on the different suffixes in the displayName attribute. Example:
#
#    displayName="Cool Name Regular"
#    displayName="Cool Name SemiBold"
#
#    Will become:  { "Regular" => {...}, "SemiBold" => {...} }
#
# 2- Get names of all TTF/OTF files in the folder and extract the variant
#   - These files are in the format Family-Variant
#
# 3- Try to match the filename variant with the variant extracted from the metadata
#   - If it matches we rename the file with the metadata attributes
#   - Otherwise alert that no match was found

require 'nokogiri'

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

def generate_filename(family:, style:, weight:, extension:)
  "%s_%s_%s.%s" % [family, style, weight, extension]
end

def longest_common_prefix(strings)
  shortest = strings.min_by(&:length)
  maxlen = shortest.length

  maxlen.downto(0) do |len|
    substr = shortest[0,len]
    return substr if strings.all?{|str| str.include? substr }
  end
end

files_metadata = {}

xml_file = File.read('./fonts/fontlist.xml')
doc = Nokogiri::XML.parse(xml_file)

display_names = doc.xpath('//font').map { |font| font['displayName'] }
display_base_name = longest_common_prefix(display_names)

if display_base_name.empty?
  abort "Could not find a display base name for font in font matadata file..."
end

puts display_base_name
display_base_name_length = display_base_name.length

doc.xpath('//font').each do |font|
  type = font['displayName'][display_base_name_length..-1]
  type_without_spaces = type.gsub(/\s+/, "")

  type_without_spaces = 'base' if type_without_spaces.empty?

  files_metadata[type_without_spaces] = {
    family: font['FamilyName'].gsub(/[^0-9a-zA-Z ]/i, ''),
    style: font['FontStyle'].downcase,
    weight: font['FontWeight'],
  }

  unless FONT_WEIGHT.keys.include?(font['FontWeight'])
    puts "[ALERT] Inconsistent weight found for type #{type}..."
  end
end

p files_metadata

filenames = Dir.glob(["./fonts/*.ttf", "./fonts/*.otf"]).map do |file|
  File.basename(file)
end

p filenames

filenames.each do |filename|
  basename, extension = filename.split('.')
  base, split, type = basename.rpartition('-')

  if split.empty?
    base = type
    type = 'base'
  end

  if files_metadata.key?(type)
    new_filename = generate_filename(
      family: files_metadata[type][:family],
      style: files_metadata[type][:style],
      weight: files_metadata[type][:weight],
      extension: extension
    )

    File.rename(File.join(Dir.pwd, 'fonts', filename), File.join(Dir.pwd, 'fonts', new_filename))
    puts "[SUCCESS] ./fonts/#{filename} renamed to #{new_filename}..."
  else
    puts "[FAILURE] #{filename} does not have metadata..."
  end
end
