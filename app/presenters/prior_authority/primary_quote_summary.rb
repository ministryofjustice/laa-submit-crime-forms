module PriorAuthority
  class PrimaryQuoteSummary
    def initialize(application)
      @application = application
    end

    attr_reader :application

    def formatted_total_cost
      # TODO: When available, add travel costs and additional costs to this
      NumberTo.pounds(service_cost_form.total_cost)
    end

    def service_cost_form
      @service_cost_form ||= Steps::ServiceCostForm.build(
        application.primary_quote,
        application:,
      )
    end

    def primary_quote_form
      @primary_quote_form ||= Steps::PrimaryQuoteForm.build(
        application.primary_quote,
        application:,
      )
    end
  end
end
