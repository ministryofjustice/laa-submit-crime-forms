require 'steps/base_form_object'

# this is a form to determine where to move next section to repeat
# an existing section, as such it does not persist anything to DB
module Steps
  class AnswerEqualityForm < Steps::BaseFormObject
    attr_reader :answer_equality

    validates :answer_equality, presence: true, inclusion: { in: YesNoAnswer.values }

    def answer_equality=(value)
      @answer_equality = value.present? ? YesNoAnswer.new(value) : nil
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
