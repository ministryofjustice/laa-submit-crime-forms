require 'rails_helper'

RSpec.describe Steps::DefendantDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      full_name:,
      maat:,
    }
  end

  let(:application) { instance_double(Claim, claim_type: claim_type, defendants: defendants, update!: true) }
  let(:defendants) { [double(:record), record] }
  let(:record) { double(:record, main:) }
  let(:main) { true }
  let(:full_name) { 'James' }
  let(:maat) { 'AA1' }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }

  describe '#maat_required' do
    context 'when claim_type is NOT BREACH_OF_INJUNCTION' do
      it { expect(subject).to be_maat_required }
    end

    context 'when claim_type is BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

      it { expect(subject).not_to be_maat_required }
    end
  end

  describe '#label_key' do
    context 'when main is true' do
      let(:main) { true }

      it { expect(subject.label_key).to eq('.main_defendant_field_set') }
    end

    context 'when main is false but all records are new records' do
      let(:main) { false }
      let(:defendants) { [instance_double(Defendant, new_record?: true)] }

      it { expect(subject.label_key).to eq('.main_defendant_field_set') }
    end

    context 'when main is false and non new records exist' do
      let(:main) { false }
      let(:defendants) { [instance_double(Defendant, new_record?: false)] }

      it { expect(subject.label_key).to eq('.defendant_field_set') }
    end
  end

  describe '#index' do
    it 'returns the position of the record in the applications defendants' do
      expect(subject.index).to eq(1)
    end
  end

  describe '#validations' do
    it { expect(subject).to be_valid }

    context 'when full name is not set' do
      let(:full_name) { nil }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:full_name, :blank)).to be(true)
      end
    end

    context 'when MAAT ID is not set' do
      let(:maat) { nil }

      context 'when claim_type is NOT BREACH_OF_INJUNCTION' do
        it 'has the appropriate error messages' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:maat, :blank)).to be(true)
        end
      end

      context 'when claim_type is BREACH_OF_INJUNCTION' do
        let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#save' do
    let(:application) { create(:claim) }
    let(:record) { Defendant.new(claim: application, id: StartPage::NEW_RECORD) }

    context 'when no defendants exist' do
      it 'created with position 1 and main true' do
        expect(subject.save).to be_truthy
        expect(application.defendants.first).to have_attributes(
          full_name: full_name,
          maat: maat,
          position: 1,
          main: true
        )
        expect(application.defendants.first).not_to have_attributes(
          id: StartPage::NEW_RECORD
        )
      end
    end

    context 'when defendants already exist' do
      before do
        create(:defendant, :valid, claim: application)
      end

      it 'created with position incremented and main false' do
        expect(subject.save).to be_truthy
        defendant = application.defendants.order(:created_at).last
        expect(defendant).to have_attributes(
          full_name: full_name,
          maat: maat,
          position: 2,
          main: false
        )
        expect(defendant).not_to have_attributes(
          id: StartPage::NEW_RECORD
        )
      end
    end

    context 'when editing an existing defendnant' do
      let(:record) { create(:defendant, :valid, claim: application) }

      it 'created with position incremented and main false' do
        expect(subject.save).to be_truthy
        expect(record.reload).to have_attributes(
          full_name: full_name,
          maat: maat,
          position: 1,
          main: true
        )
      end
    end
  end
end
