# encoding: UTF-8

require 'rest-client'

accent_base_url = "http://accent-qa.herokuapp.com"

locale_format_exception = Exception.new "Second argument should be your development language locale file path"

raise Exception.new "First argument should be your Accent project id" unless ARGV[0].to_i > 0
raise locale_format_exception unless ARGV[1]

accent_project_id = ARGV[0].to_i
locale_file = ARGV[1]

raise locale_format_exception if !File.exists?(locale_file) || File.directory?(locale_file)

acceptable_response_code = (200...300).to_a
post_revision_path = "/api/revisions?project_id=#{accent_project_id}"

response = RestClient.post("#{accent_base_url}#{post_revision_path}",{
    :revision => {
      :filename => File.basename(locale_file),
      :file     => File.new(locale_file, 'rb')
    }
  })
puts response.to_str
puts response.code

raise Exception.new "Revision upload failed" unless acceptable_response_code.include? response.code.to_i
