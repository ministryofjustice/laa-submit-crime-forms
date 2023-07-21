module CostSummary
  class Report < Base
    include GovukLinkHelper
    include ActionView::Helpers::UrlHelper

    attr_reader :claim, :items

    def initialize(claim)
      @claim = claim
      @items = {
        work_items: WorkItems.new(claim.work_items, claim),
        letters_calls: LettersCalls.new(claim),
        disbursements: Disbursements.new(claim.disbursements.by_age, claim)
      }
    end

    def sections
      items.map do |name, data|
        {
          card: {
            title: data.title,
            actions: actions(name)
          },
          rows: [header_row, *data.rows, footer_row(data)],
        }
      end
    end

    def total_cost
      NumberTo.pounds(items.values.filter_map(&:total_cost).sum)
    end

    private

    def actions(key)
      helper = Rails.application.routes.url_helpers
      [
        govuk_link_to(
          translate('.change'),
          helper.url_for(controller: "steps/#{key}", action: :edit, id: claim.id, only_path: true)
        ),
      ]
    end

    def header_row
      {
        key: { text: translate('.header.items'), classes: 'govuk-summary-list__value-width-50' },
        value: { text: translate('.header.total'), classes: 'govuk-summary-list__value-bold' },
      }
    end

    def footer_row(data)
      {
        key: { text: translate('.footer.total'), classes: 'govuk-summary-list__value-width-50' },
        value: { text: NumberTo.pounds(data.total_cost), classes: 'govuk-summary-list__value-bold' },
        classes: 'govuk-summary-list__row-double-border'
      }
    end
  end
end
