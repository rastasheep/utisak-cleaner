require 'json'
require 'gibbon'
require_relative '../hash'
require_relative '../articles'

module Campaign
  class Base
    LIST_ID = "4d1f7a5fc6"
    TEMPLATE_ID = 59409
    FROM_NAME = "Utisak"
    REPLY_TO = "aleksandar@utisak.com"

    def initialize(options = {})
      @debug = options.fetch(:debug, false)
      @segment_id = options[:segment_id] || segment_id
    end

    def execute
      @debug ? debug : send
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

    def segment_id
      raise "Not Implemented"
    end

    def subject
      raise "Not Implemented"
    end

    def articles_range
      raise "Not Implemented"
    end

    def campaign_title
      Time.now.strftime("#{subject} - %m.%d.%Y")
    end

    def campaign_settings
      {
        :type => "regular",
        :recipients => {
          :list_id => LIST_ID,
          :segment_opts => { :saved_segment_id => @segment_id }
        },
        :settings => {
          :subject_line => subject,
          :title => campaign_title,
          :from_name => FROM_NAME,
          :reply_to => REPLY_TO
        }
      }
    end

    def template_data
      { :template => { :id => TEMPLATE_ID } }.deep_merge(articles.template_data)
    end

    private

    def articles
      @articles ||= Articles.new(*articles_range)
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

    def fortmated_date(date)
      date.iso8601
    end
  end
end
