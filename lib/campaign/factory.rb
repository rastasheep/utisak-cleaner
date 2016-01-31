require_relative 'daily'
require_relative 'weekly'

class Campaign::Factory
  DAILY = "daily"
  WEEKLY = "weekly"

  attr_reader :campaign

  def execute
    campaigns.map(&:execute)
  end

  private

  def versions
    ENV["CAMPAIGN"] || campaign_version_for_date
  end

  def debug
    ENV["DEBUG"]
  end

  def segment_id
    ENV["SEGMENT"]
  end

  def campaigns
    versions.to_a.map{|version| campaign_class(version).new(:debug => debug, :segment_id => segment_id)}
  end

  def campaign_class(version)
    Object.const_get("Campaign::#{version.capitalize}")
  end

  def campaign_version_for_date
    Time.now.saturday? ? [DAILY, WEEKLY] : [DAILY]
  end
end
