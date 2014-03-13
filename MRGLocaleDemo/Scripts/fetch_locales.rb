require 'open-uri'

raise Exception.new "First argument should be the locale file path in your project" unless ARGV[0]
raise Exception.new "Second argument should be the remote locale file url to download" unless ARGV[1]

remote_url = ARGV[1]
downloaded_content = open(remote_url).read

locale_file = ARGV[0]
if downloaded_content && File.exists?(locale_file) && !File.directory?(locale_file)
  File.delete locale_file
end

if downloaded_content
  file = File.open(locale_file, "w")
  file.write downloaded_content
  file.close
end
