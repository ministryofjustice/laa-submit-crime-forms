# this is a form to determine where to move next section to repeat
# an existing section, as such it does not persist anything to DB
module Steps
  class AddAnotherForm < Steps::BaseFormObject
    attr_reader :add_another

    validates :add_another, presence: true, inclusion: { in: YesNoAnswer.values }

    def add_another=(value)
      @add_another = value.present? ? YesNoAnswer.new(value) : nil
    end

    def choices
      YesNoAnswer.values
    end

    private

    def persist!
      true
    end
  end
end
