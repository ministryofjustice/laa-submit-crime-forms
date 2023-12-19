require 'rails_helper'

RSpec.describe Assess::Uplift::RemoverForm do
  subject { implementation_class.new(claim:, current_user:, explanation:, selected_record:) }

  let(:implementation_class) { Assess::Uplift::LettersAndCallsForm::Remover }
  let(:claim) { build(:submitted_claim) }
  let(:current_user) { instance_double(User) }
  let(:explanation) { 'some reason' }
  let(:selected_record) { { 'some' => :data, 'uplift' => uplift } }
  let(:uplift) { 95 }

  describe '#validation' do
    context 'when uplift is 0' do
      let(:uplift) { 0 }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
      end
    end

    context 'when uplift is positive' do
      it { expect(subject).to be_valid }
    end

    context 'when uplift is nil' do
      let(:uplift) { nil }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
      end
    end
  end
end
