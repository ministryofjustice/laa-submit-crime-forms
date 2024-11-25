module WorkItemDetails
  extend ActiveSupport::Concern

  included do
    include WorkItemCosts
  end

  def translated_work_type(value: :original)
    key = value == :assessed ? assessed_work_type : work_type
    I18n.t("laa_crime_forms_common.nsm.work_type.#{key}")
  end

  def complete?
    Nsm::Steps::WorkItemForm.build(self, application: claim).tap { _1.add_another = 'no' }.valid?
  end
end
