require 'yaml'
require 'time'
require 'pry-byebug'

SAFE_FILENAME_REGEX = /[^0-9a-z\s]/i

def build_filename(title, timestamp)
  cleaned = title.downcase.gsub('&', 'and')
                          .gsub(SAFE_FILENAME_REGEX, '')

  parameterized = cleaned.split(' ').join('-')

  if timestamp
    iso_8601 = timestamp.strftime("%Y-%m-%d")

    "#{iso_8601}-#{parameterized}.md"
  else
    "#{parameterized}.md"
  end
end

yaml = YAML.load_file('./data/news.yml')

# Prepare target directory
target_dir = "./exports/news"
if Dir.exist?(target_dir)
  puts "Deleting entries in target directory"
  FileUtils.rm_rf Dir.glob("#{target_dir}/*")
else
  FileUtils.mkdir(target_dir)
end

yaml['news'].each do |post|
  title = post['title']

  datestamp = post['date']
  timestamp = Time.parse(datestamp) if datestamp

  filename = build_filename(title, timestamp)
  target_path = File.join(target_dir, filename)
  puts "Writing to #{target_path}"

  puts "---\n"
  puts "title: #{post['title']}\n"
  puts "author: Jane Noble\n"
  puts "status: #{post['status']}"
  puts "date: #{timestamp.strftime("%Y-%m-%d")}\n" if timestamp
  puts "published: false"
  puts "---\n\n"
  puts puts post['body']

  # File.open(target_path, 'w') do |f|
  #   f << "---\n"
  #   f << "title: \"#{title}\"\n"
  #   f << "author: \"#{author}\"\n"
  #   f << "date: #{timestamp}\n"
  #   f << "---\n\n"
  #   f << body
  # end
end
