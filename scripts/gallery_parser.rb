require 'time'
require 'pathname'
require 'pry-byebug'

class GalleryParser
  attr_reader :source_dir, :output_dir

  def initialize(source_dir, opts = {})
    @source_dir = source_dir
    @output_dir = opts.fetch(:output_dir, "./_galleries")
  end

  def images
    path_to_images = "#{source_dir}/resized/*"
    entries = Dir[path_to_images].entries
    entries.map { |path| "/uploads/#{path.split('/').last}" }
  end

  def title
    filename.gsub('-', ' ').capitalize
  end

  def filename
    source_dir.split("/").last
  end

  def datestamp
    date_numbers = filename.gsub(/[^0-9]/, '')
    Time.parse(date_numbers).strftime("%Y-%m-%d")
  rescue ArgumentError
    nil
  end

  def frontmatter
    strings = %[---
title: #{title}
date: #{datestamp}
categories:
- event
images:
]
    images.each do |image|
      strings << "- \"#{image}\"\n"
    end
    strings << "---\n\n"
    strings
  end

  def target_path
    "./_galleries/#{filename}.markdown"
  end

  def write_file
    return if Pathname.new(target).exist?
    File.open(target_path, 'w') do |f|
      f << frontmatter
    end
  end
end

source = ARGV[0]

if source.nil? || !Pathname.new(source).directory?
  raise "Path must be a directory"
end

if Pathname.new(source).directory?
  source_dirs = Dir["#{source}*"].entries
else
  source_dirs = [source]
end

source_dirs.each do |file|
  gp = GalleryParser.new(file)
  puts "Creating gallery file for: #{gp.filename}"
  # puts gp.frontmatter
  puts "Writing file to: #{gp.target_path}"
  gp.write_file
end
