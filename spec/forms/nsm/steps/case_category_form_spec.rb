require 'rails_helper'

RSpec.describe Nsm::Steps::CaseCategoryForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      plea_category:,
    }
  end

  let(:application) { create(:claim, claim_type:, youth_court:) }
  let(:plea_category) { nil }
  let(:youth_court) { 'yes' }
  let(:claim_type) { 'non_standard_magistrate' }

  describe '#validations' do
    context 'when the youth court value should be reset' do
      let(:include_youth_court_fee) { true }
      let(:plea_category) { PleaCategory::CATEGORY_1A.to_s }

      it 'ensure it resets' do
        attributes = subject.send(:attributes_to_reset)
        expect(attributes).to include(
          'include_youth_court_fee' => nil
        )
      end
    end

    context 'when the youth court value should not be reset' do
      let(:include_youth_court_fee) { true }
      let(:plea_category) { PleaCategory::CATEGORY_1B.to_s }

      it 'ensure it does not reset' do
        attributes = subject.send(:attributes_to_reset)
        expect(attributes).not_to include(
          'include_youth_court_fee' => true
        )
      end
    end
  end

  describe '#choices' do
    context 'when not breach of injunction claim type AND youth court hearing' do
      let(:youth_court) { 'yes' }
      let(:claim_type) { 'non_standard_magistrate' }

      it 'returns the correct choices' do
        expect(subject.choices).to eq(PleaCategory::WITH_YOUTH_COURT_OPTIONS)
      end
    end

    context 'when not breach of injunction claim type AND not youth court hearing' do
      let(:youth_court) { 'no' }
      let(:claim_type) { 'non_standard_magistrate' }

      it 'returns the correct choices' do
        expect(subject.choices).to eq(PleaCategory::WITHOUT_YOUTH_COURT_OPTIONS)
      end
    end

    context 'when breach of injunction claim type AND youth court hearing' do
      let(:youth_court) { 'yes' }
      let(:claim_type) { 'breach_of_injunction' }

      it 'returns the correct choices' do
        expect(subject.choices).to eq(PleaCategory::WITHOUT_YOUTH_COURT_OPTIONS)
      end
    end

    context 'when breach of injunction claim type AND not youth court hearing' do
      let(:youth_court) { 'no' }
      let(:claim_type) { 'breach_of_injunction' }

      it 'returns the correct choices' do
        expect(subject.choices).to eq(PleaCategory::WITHOUT_YOUTH_COURT_OPTIONS)
      end
    end
  end

  describe '#save' do
    context 'when plea category is set' do
      let(:plea_category) { PleaCategory::CATEGORY_1A }

      it 'is valid' do
        expect(form.save).to be_truthy
      end
    end

    context 'when plea category us not set' do
      it 'is not valid' do
        expect(form.save).not_to be_truthy
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:plea_category, :blank)).to be(true)
      end
    end
  end
end
