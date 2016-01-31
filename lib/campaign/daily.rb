require_relative 'base'

module Campaign
  class Daily < Base
    def segment_id
      12349
    end

    def subject
      "Utisak dana"
    end

    def articles_range
      return fortmated_date(Date.today - 1), fortmated_date(Date.today)
    end
  end
end
