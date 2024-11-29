require 'rails_helper'

RSpec.describe Nsm::Steps::CaseOutcomeController, type: :controller do
  let(:claim) { create(:claim, plea_category: 'category_1a') }

  before do
    allow(controller).to receive(:current_application).and_return(claim)
  end

  it_behaves_like 'a generic step controller', Nsm::Steps::CaseOutcomeForm, Decisions::DecisionTree

  describe '#set_case_outcomes' do
    context 'with category_1a plea' do
      let(:claim) { create(:claim, plea_category: 'category_1a') }

      it 'returns Category 1 outcomes' do
        expect(controller.send(:set_case_outcomes)).to eq CaseOutcome::CATEGORY_1_OUTCOMES
      end
    end

    context 'with category_1b plea' do
      let(:claim) { create(:claim, plea_category: 'category_1b') }

      it 'returns Category 1 outcomes' do
        expect(controller.send(:set_case_outcomes)).to eq CaseOutcome::CATEGORY_1_OUTCOMES
      end
    end

    context 'with category_2a plea' do
      let(:claim) { create(:claim, plea_category: 'category_2a') }

      it 'returns Category 2 outcomes' do
        expect(controller.send(:set_case_outcomes)).to eq CaseOutcome::CATEGORY_2_OUTCOMES
      end
    end

    context 'with category_2b plea' do
      let(:claim) { create(:claim, plea_category: 'category_2b') }

      it 'returns Category 2 outcomes' do
        expect(controller.send(:set_case_outcomes)).to eq CaseOutcome::CATEGORY_2_OUTCOMES
      end
    end

    context 'with invalid plea' do
      let(:claim) { create(:claim, plea_category: 'invalid') }

      it 'throws an error' do
        expect { controller.send(:set_case_outcomes) }.to raise_error(/Invalid plea category/)
      end
    end
  end
end
