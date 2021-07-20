# frozen_string_literal: true

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end
end

require_relative 'payment_terms_writer.rb'

class ThemeRewriter
  attr_reader :path

  def initialize(path)
    @path = path
    @css_path = File.join(@path, 'src/snippets/css-variables.liquid')
  end

  def perform
    if File.exists?(@css_path)
      css_content = File.read(@css_path)

      if css_content.match?('--color-body')
        puts "Found '--color-body' declaration!\n".green
      else
        puts "Couldn't find the declaration of the '--color-body' CSS variable!\n".yellow
      end
    else
      puts "Couldn't find file that sets the '--color-body' CSS variable!\n".red
    end

    liquid_files.each do |file_path|
      original_content = File.read(file_path)
      modified_content = PaymentTermsWriter.new(original_content).traverse do |f|
        puts "#{'Found:'.green}\n#{f.string}\nin\n\t#{file_path}\n\n"
        f.rewrite
      end

      if original_content.length != modified_content.length
        File.write(file_path, modified_content)
      end
    end
  end

  private

  def liquid_files
    @liquid_files ||= Dir.glob("#{path}/**/*.liquid").to_a
  end
end

theme_path = ARGV[0]
puts "Modifying #{theme_path}...\n".yellow
ThemeRewriter.new(theme_path).perform
puts "Theme modified!".yellow
