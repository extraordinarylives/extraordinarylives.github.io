require 'fileutils'
require 'httparty'
require 'pry-byebug'
require 'mini_magick'
require 'optparse'

class Downloader
  attr_reader :source_path, :opts

  def initialize(source_path, opts = {})
    @source_path = source_path
    @opts = opts
  end

  def resize_only?
    opts[:resize_only] == true
  end

  def source_file
    source_path.split('/').last
  end

  def gallery_name
    source_file.split('.')[0]
  end

  def output_dir
    "./src/images/#{gallery_name}"
  end

  def originals_root
    "#{output_dir}/originals"
  end

  def resized_root
    "#{output_dir}/resized"
  end

  def download_and_process!
    prepare_directories
    puts "Downloading images for '#{gallery_name}' gallery"

    # Download raw images from cloudinary URLs
    urls = File.readlines(source_path)
    urls.each_with_index do |url, index|
      image_number = "%03d" % (index + 1)

      # Build short url
      if url =~ /\.png\/v1/
        extension = "png"
      else
        extension = "jpg"
      end

      url_parts = url.split(/\.#{extension}\/v1/)
      short_url = "#{url_parts[0]}.#{extension}"

      # Built download location
      filename = "#{gallery_name}-#{image_number}-original.#{extension}"
      original_path = "#{originals_root}/#{filename}"

      # Fetch and save original file
      unless resize_only?
        puts "GET #{short_url}"
        resp = HTTParty.get(short_url)
        if resp.code == 200
          puts "Status: #{resp.code}"

          File.open(original_path, 'w') { |f| f << resp.body }
          puts "Created new file: #{original_path}\n"
        end
      end

      # Resized image output path. Assumes all will be converted to .jpg
      resized_filename = "#{gallery_name}-#{image_number}-large.jpg"
      resized_path = "#{resized_root}/#{resized_filename}"

      # Open original and create a resized copy
      image = MiniMagick::Image.open(original_path)
      
      # Only perform size reduction
      if image.height > 2000 || image.width > 2000
        image.resize("2000x2000")
      end

      image.format "jpg"
      image.write(resized_path)
      puts "Created new file: #{resized_path}\n"
    end
  end

  private

  def prepare_directories 
    # Create output directories
    if !Dir.exist?(output_dir)
      puts "Making new directory: #{output_dir}"
      FileUtils.mkdir(output_dir)
    end

    create_or_clean!(originals_root) unless resize_only?
    create_or_clean!(resized_root)
  end

  def create_or_clean!(path)
    if Dir.exist?(path)
      puts "Deleting entries in directory: #{path}"
      FileUtils.rm_rf Dir.glob("#{path}/*")
    else
      puts "Making new directory: #{path}"
      FileUtils.mkdir(path)
    end
  end
end

source = ARGV[0]

# raise "Path must be a file" unless Pathname.new(source).dir?
if Pathname.new(source).directory?
  source_files = Dir["#{source}*"].entries
else
  source_files = [source]
end

options = {}

begin
  OptionParser.new do |opts|
    opts.on('--force')
  end.parse!(into: options)
rescue OptionParser::InvalidOption => ex
  puts ex.message
end

if options[:force] == true
  source_files.each do |file|
    puts "Downloading files for: #{file}"
    Downloader.new(file).download_and_process!
    puts "---\n\n"
  end
  # puts source_files
else
  puts "DRY RUN. Append --force to download files from the following sources:\n\n"
  puts source_files
end
