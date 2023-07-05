require 'rails_helper'

RSpec.describe Steps::DisbursementTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      disbursement_date:,
      disbursement_type:,
      other_type:,
    }
  end

  let(:application) do
    instance_double(Claim, work_items: disbursements, update!: true)
  end
  let(:disbursements) { [double(:disbursement), record] }
  let(:disbursement_date) { Date.new(2023, 1, 1) }
  let(:record) { double(:record, id: SecureRandom.uuid) }
  let(:disbursement_type) { (DisbursementTypes.values - [DisbursementTypes::OTHER]).sample.to_s }
  let(:other_type) { nil }

  describe '#validations' do
    context 'require fields' do
      %w[disbursement_date disbursement_type].each do |field|
        describe "#when #{field} is blank" do
          let(field) { nil }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(field, :blank)).to be(true)
          end
        end
      end
    end

    describe '#when disbursement_type is other' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }

      context 'when other_type is set' do
        let(:other_type) { OtherDisbursementTypes.values.sample.to_s }

        it { expect(subject).to be_valid }
      end

      context 'when other_type is not set' do
        let(:other_type) { '' }

        it 'have an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:other_type, :blank)).to be(true)
        end
      end
    end
  end

  describe '#other_type' do
    let(:other_disbursement_type) { OtherDisbursementTypes.values.sample }
    let(:other_type) { other_disbursement_type.to_s }

    context 'when other_type_suggestion is not passed in' do
      it { expect(subject.other_type).to eq(other_disbursement_type) }
    end

    context 'when other_type_suggestion is not passed in' do
      subject(:form) { described_class.new(arguments.merge(other_type_suggestion:)) }

      context 'and it matches the translation of other type' do
        let(:other_type_suggestion) { other_disbursement_type.translated }

        it { expect(subject.other_type).to eq(other_disbursement_type) }
      end

      context 'and it does not match the translation of other type' do
        let(:other_type_suggestion) { 'Apples' }

        it { expect(subject.other_type).to eq(OtherDisbursementTypes.new('Apples')) }
      end
    end
  end

  describe 'save!' do
    let(:application) do
      Claim.create!(office_code: 'AAA')
    end
    let(:record) { Disbursement.create!(other_type: OtherDisbursementTypes::ACCOUNTANTS.to_s, claim: application) }

    context 'when disbursement_type is not other' do
      let(:disbursement_type) { DisbursementTypes::CAR.to_s }

      it 'resets the uplift value' do
        subject.save!
        expect(record.reload).to have_attributes(
          other_type: nil
        )
      end
    end

    context 'when disbursement_type is other' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }
      let(:other_type) { OtherDisbursementTypes::ACCOUNTANTS.to_s }

      it 'sets the uplift value' do
        subject.save!
        expect(record.reload).to have_attributes(
          other_type: 'accountants'
        )
      end
    end
  end
end
