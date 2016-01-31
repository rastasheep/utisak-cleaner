require 'gibbon'
require_relative 'lib/articles'

class ::Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end

articles = Articles.new

campaign_settings = {
  :type => "regular",
  :recipients => {
    :list_id => "4d1f7a5fc6",
    :segment_opts => { :saved_segment_id => 12349 }
  },
  :settings => {
    :subject_line => "Utisak dana",
    :title => Time.now.strftime("Utisak dana - %m.%d.%Y"),
    :from_name => "Utisak",
    :reply_to => "aleksandar@utisak.com"
  }
}

template_data = {
  :template => {
    :id => 59409,
    :sections => {
      :mtitle => "Yo Gari",
    }
  }
}.deep_merge(articles.template_data)

begin
  gibbon = Gibbon::Request.new
  campaign_id = gibbon.campaigns.create(:body => campaign_settings)["id"]

  gibbon.campaigns(campaign_id).content.upsert(:body => template_data)
  gibbon.campaigns(campaign_id).actions.send.create
rescue Gibbon::MailChimpError => e
  puts "Houston, we have a problem: #{e.message} - #{e.raw_body}"
end
