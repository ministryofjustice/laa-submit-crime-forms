class SummaryErrorComponent < ViewComponent::Base
  def initialize(records:, form:)
    @forms = Array(form)
    @records = records
  end

  def render?
    ! valid?
  end

  private

  def valid?
    @records.all? do |record|
      @forms.all? do |form|
        form.build(record, application: helpers.current_application).valid?
      end
    end
  end
end
