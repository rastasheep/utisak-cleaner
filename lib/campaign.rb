require 'json'
require 'gibbon'
require_relative 'hash'
require_relative 'articles'

class Campaign
  DAILY = :daily
  WEEKLY = :weekly

  LIST_ID = "4d1f7a5fc6"
  DAILY_SEGMENT_ID = 12349
  WEEKLY_SEGMENT_ID = 12349

  TEMPLATE_ID = 59409

  def initialize(type)
    @type = type
  end

  def send
    begin
      campaign_id = create_campaign
      set_campaign_data(campaign_id)
      send_campaign(campaign_id)
    rescue Gibbon::MailChimpError => e
      puts "Houston, we have a problem: #{e.message} - #{e.raw_body}"
    end
  end

  def debug
    pretty_print("Campaign settings", campaign_settings)
    pretty_print("Template data", template_data)
  end

  private

  def daily?
    @type.to_sym == DAILY
  end

  def campaign_settings
    {
      :type => "regular",
      :recipients => {
        :list_id => LIST_ID,
        :segment_opts => { :saved_segment_id => segment_id }
      },
      :settings => {
        :subject_line => subject,
        :title => campaign_title
      }
    }
  end

  def template_data
    { :template => { :id => TEMPLATE_ID } }.deep_merge(articles.template_data)
  end

  def segment_id
    daily? ? DAILY_SEGMENT_ID : WEEKLY_SEGMENT_ID
  end

  def subject
    daily? ? "Utisak dana" : "Utisak nedelje"
  end

  def campaign_title
    Time.now.strftime("#{subject} - %m.%d.%Y")
  end

  def articles
    @articles ||= Articles.new
  end

  def gibbon
    @gibon ||= Gibbon::Request.new
  end

  def create_campaign
    gibbon.campaigns.create(:body => campaign_settings)["id"]
  end

  def set_campaign_data(campaign_id)
    gibbon.campaigns(campaign_id).content.upsert(:body => template_data)
  end

  def send_campaign(campaign_id)
    gibbon.campaigns(campaign_id).actions.send.create
  end

  def pretty_print(title, data)
    puts "#{title}:\n #{JSON.pretty_generate(data)}"
  end
end
