module Assess
  module Uplift
    class LettersAndCallsForm < BaseForm
      SCOPE = 'letters_and_calls'.freeze

      class Remover < Uplift::RemoverForm
        LINKED_CLASS = V1::LetterAndCall
      end
    end
  end
end
