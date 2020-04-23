require 'fileutils'
require 'mini_magick'
require 'pry-byebug'
require 'optparse'

class ImageOptimizer
  attr_reader :source_path, :opts, :exports_path

  def initialize(source_path, opts = {})
    @source_path = source_path
    @exports_path = opts.fetch(:exports_path, "#{@source_path}/exports")
    @opts = opts
  end

  def self.generate_images(path, opts = {})
    io = self.new(path, opts)
    io.make_exports_directory
    io.create_images
  end

  def originals_path
    "#{source_path}/originals"
  end

  def source_images
    entries = Dir["#{originals_path}/*"].entries
  end

  def make_exports_directory
    return if Dir.exist?(exports_path)
    puts "Making new directory: #{exports_path}"
    FileUtils.mkdir(exports_path)
  end

  def create_images
    source_images.each do |image|
      parse_image(image)
    end
  end

  def write_image(image, original, size = nil)
    image.resize(size) unless size.nil?
    image.format("jpg")

    # dimensions = "#{image.width}x#{image.height}"
    filename = original.gsub("original", "large")
    filepath = "#{exports_path}/#{filename}"

    image.write(filepath)
    puts "Created new file: #{filepath}\n"
    filepath
  end

  def export_original?(image)
    return true if image.width < 640 && image.height < 640
    return true if image.width > 640 && image.width < 1600
    false
  end

  def parse_image(image_path)
    image = MiniMagick::Image.open(image_path)
    filename = Pathname.new(image_path).split.last.to_s
    
    # Only resize if reducing resolution
    if image.width >= 1600 || image.height >= 1600
      new_file = write_image(image, filename, "1600x1600")

      puts "Optimizing image: #{new_file}"
      MiniMagick::Tool::Convert.new do |convert|
        convert << new_file

        # Adjust density on outputted file is necessary
        if image.resolution != [72, 72]
          convert.merge! ["-density", "72x72"]
        end

        # Reduce quality to 90% to optimize file size
        convert.merge! ["-quality", "90"]
        convert << new_file
      end
    else
      # Copy original file
      new_file = write_image(image, filename)
    end
  end
end

source = ARGV[0]
source = source.chop if source.split('').last == "/"

raise "Invalid source" unless Dir.exist?(source)
raise "Path must be a directory" unless Pathname.new(source).directory?

options = {}
begin
  OptionParser.new do |opts|
    opts.on('--single')
    opts.on('--dryrun')
  end.parse!(into: options)
rescue OptionParser::InvalidOption => ex
  puts ex.message
end

if options[:single] && Pathname.new(source).directory?
  source_dirs = [source]
else
  source_dirs = Dir["#{source}/*"].entries

  # Reject directories with underscores
  source_dirs.reject! do |dir|
    dir_name = Pathname.new(dir).split.last.to_s
    dir_name[0] == "_"
  end
end

if options[:dryrun]
  puts "[DRYRUN] Will generate images for these directories:"
  puts source_dirs
else
  source_dirs.each do |dir|
    # ImageOptimizer.generate_images(dir, exports_path: "./_uploads")
    ImageOptimizer.generate_images(dir, exports_path: "./src/images/sponsors/exports")
  end
end
