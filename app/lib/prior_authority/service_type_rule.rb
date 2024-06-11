module PriorAuthority
  class ServiceTypeRule
    # rubocop:disable Metrics/MethodLength
    # This is an unusually long method because it's essentially config
    def self.build(service_type)
      case service_type
      when QuoteServices::PSYCHIATRIC_REPORT_PRISON_LAW,
           QuoteServices::PSYCHOLOGICAL_REPORT_PRISON_LAW,
           QuoteServices::INTERPRETER
        new(court_order_relevant: true)
      when QuoteServices::PATHOLOGIST_REPORT
        new(post_mortem_relevant: true)
      when QuoteServices::TRANSCRIPTION_RECORDING,
           QuoteServices::TRANSLATION_AND_TRANSCRIPTION
        new(cost_type: :per_item, item: 'minute')
      when QuoteServices::TRANSLATION_DOCUMENTS
        new(cost_type: :per_item, item: 'word', cost_item: 'thousand_words', cost_multiplier: BigDecimal('0.001'))
      when QuoteServices::PHOTOCOPYING
        new(cost_type: :per_item, item: 'page')
      when QuoteServices::DNA_REPORT,
           QuoteServices::METEOROLOGIST,
           QuoteServices::BACK_CALCULATION,
           QuoteServices.new(:custom)
        new(cost_type: :variable)
      else
        new
      end
    end
    # rubocop:enable Metrics/MethodLength

    def initialize(court_order_relevant: false, post_mortem_relevant: false, cost_type: :per_hour, item: 'item',
                   cost_item: item, cost_multiplier: 1)
      @court_order_relevant = court_order_relevant
      @post_mortem_relevant = post_mortem_relevant
      @cost_type = cost_type
      @item = item
      @cost_item = cost_item
      @cost_multiplier = cost_multiplier
    end

    attr_reader :court_order_relevant, :post_mortem_relevant, :cost_type, :item, :cost_item, :cost_multiplier
  end
end
