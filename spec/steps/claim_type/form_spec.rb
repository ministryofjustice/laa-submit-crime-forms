require 'rails_helper'

RSpec.describe Steps::ClaimTypeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      claim_type:,
      rep_order_date:,
      cntp_date:,
      cntp_order:
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:claim_type) { nil }
  let(:rep_order_date) { nil }
  let(:cntp_date) { nil }
  let(:cntp_order) { nil }

  describe '#save' do
    context 'when `claim_type` is blank' do
      let(:claim_type) { '' }

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:claim_type, :inclusion)).to be(true)
      end
    end

    context 'when `claim_type` is invalid' do
      let(:claim_type) { 'invalid_type' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:claim_type, :inclusion)).to be(true)
      end
    end

    context 'when `claim_type` is valid' do
      let(:claim_type) { ClaimType::SOMETHING_ELSE.to_s }

      it { is_expected.to be_valid }

      it 'passes validation' do
        expect(form.errors.of_kind?(:claim_type, :invalid)).to be(false)
      end

      context 'when non-standard magistrate claim_type' do
        let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }

        context 'with a rep order date' do
          let(:rep_order_date) { Date.new(2023, 4, 1) }
          let(:cntp_datee) { Date.new(2023, 4, 1) }
          let(:cntp_order) { 'AAAA' }

          it { is_expected.to be_valid }

          it 'can reset CNTP fields (leave rep order date)' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes).to eq(
              'rep_order_date' => rep_order_date,
              'cntp_order' => nil,
              'cntp_date' => nil,
            )
          end
        end

        context 'without a rep order date' do
          it 'is invalid' do
            expect(form).not_to be_valid
            expect(form.errors.of_kind?(:rep_order_date, :blank)).to be(true)
          end
        end
      end

      context 'when breach of injunction claim type' do
        let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

        context 'with a CNTP fields being set' do
          let(:rep_order_date) { Date.new(2023, 4, 1) }
          let(:cntp_date) { Date.new(2023, 4, 1) }
          let(:cntp_order) { 'AAAA' }

          it 'is valid' do
            expect(form).to be_valid
          end

          it 'can reset rep order date (leave CNTP fields)' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes).to eq(
              'rep_order_date' => nil,
              'cntp_order' => cntp_order,
              'cntp_date' => cntp_date,
            )
          end
        end

        context 'without a CNTP fields being set' do
          it 'is also valid' do
            expect(form).not_to be_valid
            expect(form.errors.of_kind?(:cntp_order, :blank)).to be(true)
            expect(form.errors.of_kind?(:cntp_date, :blank)).to be(true)
          end
        end

        context 'without a CNTP date in the future being set' do
          let(:cntp_date) { 3.days.from_now.to_date }
          let(:cntp_order) { 'AAAA' }

          it 'is also valid' do
            expect(form).not_to be_valid
            expect(form.errors.of_kind?(:cntp_order, :blank)).to be(false)
            expect(form.errors.of_kind?(:cntp_date, :future_not_allowed)).to be(true)
          end
        end
      end

      context 'when claim type is `something else`' do
        let(:claim_type) { ClaimType::SOMETHING_ELSE.to_s }

        context 'with details of what has changed' do
          let(:rep_order_date) { Date.new(2023, 4, 1) }
          let(:cntp_date) { Date.new(2023, 4, 1) }
          let(:cntp_order) { 'AAAA' }

          it 'is valid' do
            expect(form).to be_valid
          end

          it 'can reset all CNTP and rep order fields' do
            attributes = form.send(:attributes_to_reset)
            expect(attributes).to eq(
              'rep_order_date' => nil,
              'cntp_order' => nil,
              'cntp_date' => nil,
            )
          end
        end
      end
    end
  end
end
