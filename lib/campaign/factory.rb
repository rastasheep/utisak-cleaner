require_relative 'daily'
require_relative 'weekly'

class CampaignFactory
  DAILY = "daily"
  WEEKLY = "weekly"

  def initialize
    @campaign = campaign_class.new(:debug => debug, :segment_id => segment_id)
  end

  def execute
    @campaign.execute
  end

  private

  def version
    ENV["CAMPAIGN"] || campaign_version_from_date
  end

  def debug
    ENV["DEBUG"]
  end

  def segment_id
    ENV["SEGMENT"]
  end

  def campaign_class
    Object.const_get("Campaign::#{version.capitalize}")
  end

  def campaign_version_from_date
    Time.now.saturday? ? WEEKLY : DAILY
  end
end
