module Assess
  class BaseAdjustmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :claim
    attribute :explanation, :string
    attribute :current_user
    attribute :item # used to detect changes in data

    validates :claim, presence: true
    validates :explanation, presence: true, if: :explanation_required?
    validate :data_changed

    private

    def process_field(value:, field:)
      return if selected_record[field] == value

      # does this belong in the Event object as that is where it is
      # created for everything else? as that would require passing a
      # lot of varibles across....
      details = {
        field: field,
        from: selected_record[field],
        to: value,
        comment: explanation
      }
      # TODO: uncomment once work_type edits are implemented as they won't have a change
      # details[:change] = value - selected_record[field] if value.methods.include?(:'-')
      details[:change] = value - selected_record[field]

      selected_record[field] = value
      Event::Edit.build(claim:, details:, linked:, current_user:)
    end

    def linked
      {
        type: self.class::LINKED_CLASS::LINKED_TYPE,
        id: selected_record.dig(*self.class::LINKED_CLASS::ID_FIELDS),
      }
    end

    def data_changed
      return if data_has_changed?

      errors.add(:base, :no_change)
    end

    def explanation_required?
      data_has_changed?
    end

    # :nocov:
    def data_has_changed?
      raise 'implement in class'
    end

    def selected_record
      raise 'implement in class'
    end
    # :nocov:
  end
end
