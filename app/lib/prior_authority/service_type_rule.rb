module PriorAuthority
  class ServiceTypeRule
    # rubocop:disable Metrics/MethodLength
    # This is an unusually long method because it's essentially config
    def self.build(service_type)
      case service_type
      when QuoteServices::PSYCHIATRIC_REPORT_PRSN_LAW,
           QuoteServices::PSYCHOLOGICAL_REPORT_PRSN_LAW,
           QuoteServices::INTERPRETERS
        new(court_order_relevant: true)
      when QuoteServices::PATHOLOGIST
        new(post_mortem_relevant: true)
      when QuoteServices::TRANSCRIPTS_RECORDINGS,
           QuoteServices::TRANSLATION_AND_TRANSCRIPTION_WORD
        new(cost_type: :per_item, item: 'minute')
      when QuoteServices::TRANSLATOR_DOCUMENTS
        new(cost_type: :per_item, item: 'word')
      when QuoteServices::PHOTOCOPYING_PER_SHEET
        new(cost_type: :per_item, item: 'page')
      when QuoteServices::DNA_PER_PERSON,
           QuoteServices::METEOROLOGIST,
           QuoteServices::BACK_CALCULATIONS,
           QuoteServices.new(:custom)
        new(cost_type: :variable)
      else
        new
      end
    end
    # rubocop:enable Metrics/MethodLength

    def initialize(court_order_relevant: false, post_mortem_relevant: false, cost_type: :per_hour, item: 'item')
      @court_order_relevant = court_order_relevant
      @post_mortem_relevant = post_mortem_relevant
      @cost_type = cost_type
      @item = item
    end

    attr_reader :court_order_relevant, :post_mortem_relevant, :cost_type, :item
  end
end
