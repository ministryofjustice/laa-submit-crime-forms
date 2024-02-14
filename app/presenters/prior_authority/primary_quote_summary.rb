module PriorAuthority
  class PrimaryQuoteSummary
    def initialize(application)
      @application = application
    end

    attr_reader :application

    def formatted_total_cost
      NumberTo.pounds(
        service_cost_form.total_cost +
        (travel_detail_form.valid? ? travel_detail_form.total_cost : 0) +
        additional_cost_overview_form.total_cost
      )
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

    def travel_detail_form
      @travel_detail_form ||= Steps::TravelDetailForm.build(
        application.primary_quote,
        application:,
      )
    end

    def additional_cost_overview_form
      @additional_cost_overview_form ||= Steps::AdditionalCosts::OverviewForm.build(application)
    end
  end
end
