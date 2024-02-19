module PriorAuthority
  module CheckAnswers
    class PrimaryQuoteCardSummary
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::UrlHelper
      include Rails.application.routes.url_helpers
      include ActionView::Context

      include GovukLinkHelper
      include GovukVisuallyHiddenHelper

      attr_reader :application

      delegate :t!, :t, to: I18n

      def initialize(application)
        @application = application
      end

      def quote_summary
        @quote_summary ||= PriorAuthority::PrimaryQuoteSummary.new(application)
      end

      def render
        # ApplicationController.render('prior_authority/steps/check_answers/_primary_quote')

        # ActionView::Base
        #   .new(ActionController::Base.view_paths, {})
        #   .render(file: 'prior_authority/steps/check_answers/_primary_quote',
        #           layout: 'layouts/prior_authority')

        # lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)
        # context = ActionView::Base.with_empty_template_cache.new(lookup_context, {}, nil)

        # renderer = ActionView::Renderer.new(lookup_context)
        # renderer.render(context, { file: 'app/views/prior_authority/steps/check_answers/_primary_quote' })

        summary_card
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
      def summary_card
        tag.div(class: 'govuk-summary-card') do
          concat(
            tag.div(class: 'govuk-summary-card__title-wrapper') do
              concat tag.h2(class: 'govuk-summary-card__title') { 'My title'}
            end
          )
          concat(
            tag.ul(class: 'govuk-summary-card__actions') do
              concat(
                tag.li(class: 'govuk-summary-card__action') do
                  # concat tag.govuk_link_to('Change', edit_prior_authority_steps_primary_quote_path(application))
                  concat tag.span(class: 'govuk-visually-hidden') { 'Change' }
                end
              )
            end
          )
        end
      end

      # TODO: should use a unordered list not a table
      def summary_table
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
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
      end
    end
  end
end
