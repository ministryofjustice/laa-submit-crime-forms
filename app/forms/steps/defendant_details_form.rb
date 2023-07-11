require 'steps/base_form_object'

module Steps
  class DefendantDetailsForm < Steps::BaseFormObject
    attribute :full_name, :string
    attribute :maat, :string

    validates :full_name, presence: true
    validates :maat, presence: true, if: :maat_required?

    def maat_required?
      application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
    end

    def label_key
      ".#{'main_' if main_record?}defendant_field_set"
    end

    def index
      application.defendants.index(record)
    end

    private

    def persist!
      record.id = nil if record.id == StartPage::NEW_RECORD
      record.update!(attributes.merge(position_attributes))
    end

    def position_attributes
      return {} if record.position

      prev_position = application.defendants.maximum(:position)
      if prev_position
        { position: prev_position + 1, main: false }
      else
        { position: 1, main: true }
      end
    end

    def main_record?
      # check if it set on the DB record
      return true if record.main

      # DB query to check if any records in DB - ignoring this one which is unsaved
      application.defendants.count.zero?
    end
  end
end
