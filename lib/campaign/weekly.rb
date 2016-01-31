require_relative 'base'

module Campaign
  class Weekly < Base
    def segment_id
      15437
    end

    def subject
      "Utisak nedelje"
    end

    def articles_range
      return fortmated_date(Date.today - 7), fortmated_date(Date.today)
    end
  end
end
