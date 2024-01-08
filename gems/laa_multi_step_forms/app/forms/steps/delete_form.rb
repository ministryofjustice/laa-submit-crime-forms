module Steps
  class DeleteForm < Steps::BaseFormObject
    attribute :id

    private

    def persist!
      record.destroy
    end
  end
end
