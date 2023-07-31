class SummaryErrorComponent < ViewComponent::Base
  def initialize(records:, form:)
    @form = form
    @records = records
  end

  def forms
    @forms ||= @records.map { |record| @form.build(record, application: helpers.current_application) }
  end

  def render?
    !forms.all?(&:valid?)
  end
end
