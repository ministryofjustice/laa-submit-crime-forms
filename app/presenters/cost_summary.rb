class CostSummary
  include GovukLinkHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper

  attr_reader :claim

  def initialize(claim)
    @claim = claim
  end

  def sections
    [
      { card: { title: t("work_items"), actions: actions(:work_items) }, rows: work_items_data },
      { card: { title: t("letters_calls"), actions: actions(:letters_calls) }, rows: letters_calls_data },
    ]
  end

  def actions(key)
    [
      # GovukComponent::SummaryListComponent::ActionComponent.new(href: "#", visually_hidden_text: "Emboar's defence statistics"),
      govuk_link_to(t(".change"), send("edit_steps_#{key}_path", claim)),
    ]
  end

  def work_items_data
    [
      header_row,
      *work_items,
      total_row(work_item_forms)
    ]
  end

  def letters_calls_data
    [
      header_row,
      letters_row,
      calls_row,
      total_row([letters_calls_form])
    ]
  end

  private

  def header_row
    {
      key: { text: t(".header.items") },
      value: { text: t(".header.total"), classes: 'govuk-summary-list__value-bold' },
    }
  end

  def work_items
    forms = work_item_forms.group_by(&:work_type)
    work_types = WorkTypes.values.filter { |work_type| work_type.display?(claim) }

    work_types.map do |work_type|
      total_cost = forms[work_type]&.sum(&:total_cost).to_f || 0.0
      {
        key: { text: t(work_type.to_s) },
        value: { text: f(total_cost) },
      }
    end
  end

  def work_item_forms
    @work_item_forms = claim.work_items
                            .map { |work_item| Steps::WorkItemForm.build(work_item, application: claim) }
  end

  def letters_row
    {
      key: { text: t("letters") },
      value: { text: f(letters_calls_form.letters_total) },
    }
  end

  def calls_row
    {
      key: { text: t("calls") },
      value: { text: f(letters_calls_form.calls_total) },
    }
  end

  def letters_calls_form
    @letters_calls_form ||= Steps::LettersCallsForm.build(claim)
  end

  def total_row(items)
    {
      key: { text: t(".footer.total") },
      value: { text: f(items.sum(&:total_cost)), classes: 'govuk-summary-list__value-bold' },
      classes: 'govuk-summary-list__row-double-border'
    }

  end

  def t(key)
    if key[0] == ('.')
      I18n.t("summary.#{key}")
    else
      I18n.t("summary.#{self.class.to_s.underscore}.#{key}")
    end
  end

  def f(value)
    number_to_currency(value, unit: '£')
  end
end