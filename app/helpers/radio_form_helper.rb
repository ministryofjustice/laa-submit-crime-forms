module RadioFormHelper
  def radio_legend(text)
    heading = tag.h1(t('.heading'), class: %w( govuk-fieldset__heading ))
    tag.legend(heading, class: %w(govuk-fieldset__legend govuk-fieldset__legend--l))
  end
end
