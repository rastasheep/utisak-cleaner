require 'date'
require 'swiftype'

Swiftype.api_key = ENV['SWIFTYPE_KEY']

client = Swiftype::Client.new

engine = 'utisak'
document_type = 'posts'
query = ''
per_page = 100
older_than = Date.today - 15 # 15 days

current_page = 1
external_ids = []

def pretty_print(msg)
  puts msg
  puts '-' * 80
end

loop do
  results = client.search(
    engine,
    query,
    :filters => {
      'posts' => {
        'published_at' => {
          'type' => 'range',
          'to' => older_than
        }
      }
    },
    :per_page => per_page,
    :page => current_page)

  if current_page == 1
    pretty_print(
      "Matched documents:\n" \
      "- total: #{results.total_result_count(document_type)} \n" \
      "- pages: #{results.num_pages}")
  end

  external_ids << results[document_type].map { |post| post['external_id'] }

  break if current_page >= results.num_pages
  current_page += 1
end

external_ids.flatten!

pretty_print(
  "To delete: #{external_ids.size}\n" \
  "Sample: #{external_ids[1..20]}")

external_ids.each_slice(per_page) do |slice|
  response = client.destroy_documents(engine, document_type, slice)

  results = Hash[slice.zip response]

  failed = results.select { |_key, value| !value }.keys
  pretty_print(
    "Failed to delete: (#{failed.size} of #{slice.size})\n"\
    "- #{failed}")
end

pretty_print 'Done!'
