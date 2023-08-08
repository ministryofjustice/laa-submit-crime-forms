require 'rails_helper'

RSpec.describe LaaMultiStepForms::CheckMissingHelper, type: :helper do
  describe '#check_missing' do
    context 'when value is false' do
      it 'renders the missing tag' do
        expect(helper.check_missing(false)).to eq('<strong class="govuk-tag govuk-tag--red">Incomplete</strong>')
      end
    end

    context 'when value is truthy' do
      context 'and no block is passed in' do
        it 'renders the value' do
          expect(helper.check_missing('apples')).to eq('apples')
        end
      end

      context 'and ablock is passed in' do
        it 'renders block' do
          response = helper.check_missing('apples') do
            'pears'
          end
          expect(response).to eq('pears')
        end
      end
    end
  end
end
