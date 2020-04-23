images = %w[
  piggie-bear-casa-hogar-2.png
  piggie-bear-fairmont-school.jpg
  piggie-bear-hope-alliance-2.jpg
  piggie-bear-casa-hogar.jpg
  piggie-bear-lydia-mclaughlin.jpg
  piggie-bear-cap-usd.jpg
  piggie-bear-high-five-event-2.jpg
  piggie-bear-high-five-event.jpg
  piggie-bear-choc-childrens.jpg
  piggie-bear-hope-alliance.jpg
  piggie-bear-horace-mann-2.jpg
  piggie-bear-tennis-serves-others.jpg
  piggie-bear-horace-mann.png
  piggie-bear-100-women.jpg
  piggie-bear-poppy-jamie.jpg
]

images.each do |image|
  image_name = image.split('.').first
  file_title = image_name.split(/piggie-bear-/).last
  event_title = file_title.split('-')
                          .map { |word| word.capitalize }
                          .join(' ')

  file_path = "./_book_readings/#{file_title}.markdown"

  File.open(file_path, 'w') do |f|
    f << "---\n"
    f << "title: #{event_title}\n"
    f << "image: \"/uploads/#{image}\"\n"
    f << "---\n"
  end

  puts "New file: #{file_path}"
end
