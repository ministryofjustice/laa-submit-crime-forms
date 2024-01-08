module Steps
  class DefendantDeleteForm < Steps::BaseFormObject
    attribute :id

    def caption_key
      if record.main
        '.main_defendant'
      else
        '.additional_defendant'
      end
    end

    private

    def persist!
      record.destroy
    end
  end
end
