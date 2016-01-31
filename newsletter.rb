require_relative 'lib/campaign'

class CampaignFactory
  CAMPAIGN_VERSIONS = [Campaign::DAILY, Campaign::WEEKLY]

  def initialize
    @campaign = Campaign.new(version)
  end

  def execute
    ENV.key?("DEBUG") ? debug : send
  end

  def send
    @campaign.send
  end

  def debug
    @campaign.debug
  end

  def version
    ENV.key?("CAMPAIGN_VER") ? campaign_version_from_env : campaign_version_from_date
  end

  private

  def campaign_version_from_env
    version = ENV["CAMPAIGN_VER"].to_sym
    CAMPAIGN_VERSIONS.include?(version) ? version : Campaign::DAILY
  end

  def campaign_version_from_date
    Time.now.saturday? ? Campaign::WEEKLY : Campaign::DAILY
  end
end

CampaignFactory.new.execute
