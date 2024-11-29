class SearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  Option = Struct.new(:value, :label)

  attribute :search_string, :string
  attribute :submitted_from, :date
  attribute :submitted_to, :date
  attribute :updated_from, :date
  attribute :updated_to, :date
  attribute :state, :string
  attribute :office_code, :string
  attribute :current_provider

  validate :at_least_one_attribute_set

  def submitted?
    !search_string.nil?
  end

  def at_least_one_attribute_set
    errors.add(:base, :no_attributes_set) if attributes.except('current_provider').values.none?(&:present?)
  end

  def office_codes
    [show_all] + current_provider.office_codes.map { Option.new(_1, _1) }
  end

  def states
    [show_all] + %i[
      draft
      submitted
      sent_back
      provider_updated
      granted
      part_grant
      rejected
      expired
    ].map { Option.new(_1, I18n.t("prior_authority.states.#{_1}")) }
  end

  def show_all
    @show_all ||= Option.new('', I18n.t('shared.search.show_all'))
  end
end
