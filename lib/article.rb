class Article
  def initialize(article_json)
    @source = article_json
  end

  def sections(index)
    {
      area_label("title" ,index) => title,
      area_label("content", index) => @source["excerpt"]
    }
  end

  private

  def area_label(name, index)
    sprintf("article_%02d_#{name}", index).to_sym
  end

  def title
    "<a href='#{@source["share_url"]}'>#{@source["title"]}</a>"
  end
end
