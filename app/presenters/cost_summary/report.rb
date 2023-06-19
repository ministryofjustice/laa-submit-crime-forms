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
      }
    end

    def sections
      items.map do |name, data|
        {
          card: {
            title: data.title,
            actions: actions(name)
          },
          rows: [header_row] + data.rows
        }
      end
    end

    def total_cost
      f(items.values.sum(&:total_cost))
    end

    def actions(key)
      helper = Rails.application.routes.url_helpers
      [
        govuk_link_to(
          t('.change'),
          helper.url_for(controller: "steps/#{key}", action: :edit, id: claim.id, only_path: true)
        ),
      ]
    end

    private

    def header_row
      {
        key: { text: t('.header.items') },
        value: { text: t('.header.total'), classes: 'govuk-summary-list__value-bold' },
      }
    end
  end
end
