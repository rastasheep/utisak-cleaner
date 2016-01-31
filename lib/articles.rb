require "json"
require "faraday"
require_relative "article"

class Articles
  UTISAK_API="https://api.utisak.com"

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    @articles = fetch
  end

  def template_data
    { :template => { :sections => sections_data } }
  end

  private

  def sections_data
    @articles.each_with_index.map{|article, index| article.sections(index)}.inject(:merge)
  end

  def fetch
    response = connection.get "/vesti", {"start-date" => @start_date, "end-date" => @end_date}
    posts = JSON.parse(response.body)["posts"]
    posts.map{|post| Article.new(post)}
  end

  def connection
    @connection ||= Faraday.new(:url => UTISAK_API) do |faraday|
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end
end
