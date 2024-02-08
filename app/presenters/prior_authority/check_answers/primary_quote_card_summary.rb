module PriorAuthority
  module CheckAnswers
    class PrimaryQuoteCardSummary
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Context

      attr_reader :application

      delegate :t!, to: I18n

      def initialize(application)
        @application = application
      end

      def quote_summary
        @quote_summary ||= PriorAuthority::PrimaryQuoteSummary.new(application)
      end

      # TODO: should use a unordered list not a table
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
      def render
        tag.table(class: 'govuk-table') do
          concat(
            tag.thead(class: 'govuk-table__head') do
              tag.tr(class: 'govuk-table__row') do
                concat tag.th(scope: 'col', class: 'govuk-table__header') { 'Costs' }
                concat tag.th(scope: 'col', class: 'govuk-table__header') { 'Total' }
              end
            end
          )
          concat(
            tag.tbody(class: 'govuk-table__body') do
              tag.tr(class: 'govuk-table__row') do
                concat tag.td(scope: 'col', class: 'govuk-table__cell') { 'Service' }
                concat tag.td(scope: 'col', class: 'govuk-table__cell') {
                  NumberTo.pounds(quote_summary.service_cost_form.total_cost)
                }
              end
            end
          )
          concat(
            tag.tbody(class: 'govuk-table__body') do
              tag.tr(class: 'govuk-table__row') do
                concat tag.td(scope: 'col', class: 'govuk-table__cell') { 'Travel' }
                concat tag.td(scope: 'col', class: 'govuk-table__cell') {
                  NumberTo.pounds(quote_summary.travel_detail_form.total_cost)
                }
              end
            end
          )
          concat(
            tag.tbody(class: 'govuk-table__body') do
              tag.tr(class: 'govuk-table__row') do
                concat tag.td(scope: 'col', class: 'govuk-table__cell') { 'Additional' }
                concat tag.td(scope: 'col', class: 'govuk-table__cell') {
                  NumberTo.pounds(quote_summary.additional_cost_overview_form.total_cost)
                }
              end
            end
          )
          concat(
            tag.tfoot(class: 'govuk-table__body') do
              tag.tr(class: 'govuk-table__row') do
                concat tag.td(scope: 'col', class: 'govuk-table__cell') { tag.strong 'Total cost' }
                concat tag.td(scope: 'col', class: 'govuk-table__cell') {
                  tag.strong quote_summary.formatted_total_cost
                }
              end
            end
          )
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
    end
  end
end
