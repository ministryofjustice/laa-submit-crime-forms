class OfficeForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :provider
  attribute :selected_office_code, :string

  validates :selected_office_code, presence: true

  def save
    return false unless valid?

    provider.update!(selected_office_code:)
    true
  end

  def choices
    provider.office_codes
  end
end
