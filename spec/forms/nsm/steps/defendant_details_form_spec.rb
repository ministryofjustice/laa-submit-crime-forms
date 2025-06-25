require 'rails_helper'

RSpec.describe Nsm::Steps::DefendantDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      first_name:,
      last_name:,
      maat:,
    }
  end

  let(:application) { instance_double(Claim, claim_type: claim_type, defendants: defendants, update!: true) }
  let(:defendants) { [double(:record), record] }
  let(:record) { double(:record, main:) }
  let(:main) { true }
  let(:first_name) { 'James' }
  let(:last_name) { 'Smith' }
  let(:maat) { '1234567' }
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

    context 'when main is nil' do
      let(:main) { false }

      context 'and defendant count is zero' do
        let(:defendants) { double(:defendants, count: 0) }

        it { expect(subject.label_key).to eq('.main_defendant_field_set') }
      end

      context 'and defendant count is non-zero' do
        let(:defendants) { double(:defendants, count: 1) }

        it { expect(subject.label_key).to eq('.defendant_field_set') }
      end
    end
  end

  describe '#index' do
    it 'returns the position of the record in the applications defendants' do
      expect(subject.index).to eq(1)
    end
  end

  describe '#validations' do
    it { expect(subject).to be_valid }

    context 'when first name is not set' do
      let(:first_name) { nil }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:first_name, :blank)).to be(true)
      end
    end

    context 'when last name is not set' do
      let(:last_name) { nil }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:last_name, :blank)).to be(true)
      end
    end

    context 'when MAAT ID number is an expected value' do
      let(:maat) { '4900900' }

      it { is_expected.to be_valid }
    end

    context 'when MAAT ID number is not set' do
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

    context 'when MAAT ID number contains letters' do
      let(:maat) { '123456A' }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:maat, :invalid)).to be(true)
      end
    end

    context 'when MAAT ID number is too short' do
      let(:maat) { '12345' }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:maat]).to include('The MAAT ID number must be a 7 digit number')
      end
    end
  end

  describe '#save' do
    let(:application) { create(:claim) }
    let(:record) { Defendant.new(defendable: application, id: Nsm::StartPage::NEW_RECORD) }

    context 'when no defendants exist' do
      it 'created with position 1 and main true' do
        expect(subject.save).to be_truthy
        expect(application.defendants.first).to have_attributes(
          first_name: first_name,
          last_name: last_name,
          maat: maat,
          position: 1,
          main: true
        )
        expect(application.defendants.first).not_to have_attributes(
          id: Nsm::StartPage::NEW_RECORD
        )
      end
    end

    context 'when defendants already exist' do
      before do
        create(:defendant, :valid, defendable: application)
      end

      it 'created with position incremented and main false' do
        expect(subject.save).to be_truthy
        defendant = application.defendants.order(:created_at).last
        expect(defendant).to have_attributes(
          first_name: first_name,
          last_name: last_name,
          maat: maat,
          position: 2,
          main: false
        )
        expect(defendant).not_to have_attributes(
          id: Nsm::StartPage::NEW_RECORD
        )
      end
    end

    context 'when editing an existing defendnant' do
      let(:record) { create(:defendant, :valid, defendable: application) }

      it 'created with position incremented and main false' do
        expect(subject.save).to be_truthy
        expect(record.reload).to have_attributes(
          first_name: first_name,
          last_name: last_name,
          maat: maat,
          position: 1,
          main: true
        )
      end
    end
  end

  describe '#maat_if_valid?' do
    context 'when maat is valid' do
      let(:maat) { '1234567' }

      it 'returns the maat' do
        expect(subject.maat_if_valid).to eq '1234567'
      end
    end

    context 'when maat is invalid' do
      let(:maat) { '123456' }

      it 'returns nil' do
        expect(subject.maat_if_valid).to be_nil
      end
    end
  end

  describe '#full_name_if_valid?' do
    context 'when full name is valid' do
      it 'returns the full name' do
        expect(subject.full_name_if_valid).to eq 'James Smith'
      end
    end

    context 'when full name is invalid' do
      let(:first_name) { '' }

      it 'returns nil' do
        expect(subject.full_name_if_valid).to be_nil
      end
    end
  end
end
