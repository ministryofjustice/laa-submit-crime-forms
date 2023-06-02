require 'steps/base_form_object'

# TODO: move this to the engine

# This is a generic form to allow a yes no question to be asked in the view
# the responce is then used in the DecisionTree to determine the destination
# without persisting anything to the DB
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
