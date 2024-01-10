module Steps
  class DisbursementTypeForm < Steps::BaseFormObject
    attribute :disbursement_date, :multiparam_date
    attribute :disbursement_type, :value_object, source: DisbursementTypes
    attribute :other_type, :value_object, source: OtherDisbursementTypes

    validates :disbursement_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false }
    validates :disbursement_type, presence: true, inclusion: { in: DisbursementTypes.values }
    # does not have inclusion validator as value can be outside list
    validates :other_type, presence: true, if: :other_disbursement_type?

    def other_type_suggestion=(value)
      return if other_type && OtherDisbursementTypes.new(other_type).translated == value

      self.other_type = value
    end

    private

    def persist!
      record.id = nil if record.id == StartPage::NEW_RECORD
      record.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge('other_type' => other_disbursement_type? ? other_type : nil)
    end

    def other_disbursement_type?
      disbursement_type&.other?
    end
  end
end
