require 'rails_helper'

RSpec.describe Steps::LettersCallsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      letters:,
      calls:,
      apply_letters_uplift:,
      letters_uplift:,
      apply_calls_uplift:,
      calls_uplift:,
    }
  end

  let(:application) { instance_double(Claim, update!: true, date: date, reasons_for_claim: reasons_for_claim) }
  let(:letters) { 1 }
  let(:calls) { 1 }
  let(:apply_letters_uplift) { 'true' }
  let(:letters_uplift) { 0 }
  let(:apply_calls_uplift) { 'true' }
  let(:calls_uplift) { 0 }
  let(:date) { nil }
  let(:reasons_for_claim) { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }

  describe '#validations' do
    describe '#letters' do
      context 'is negative' do
        let(:letters) { -1 }

        it 'have an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:letters, :greater_than_or_equal_to)).to be(true)
        end
      end

      context 'is blank' do
        let(:letters) { '' }

        it 'have an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:letters, :blank)).to be(true)
        end
      end

      context 'is zero' do
        let(:letters) { 0 }

        it { expect(subject).to be_valid }
      end

      context 'is positive' do
        let(:letters) { 1 }

        it { expect(subject).to be_valid }
      end
    end

    describe '#calls' do
      context 'is negative' do
        let(:calls) { -1 }

        it 'have an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:calls, :greater_than_or_equal_to)).to be(true)
        end
      end

      context 'is blank' do
        let(:calls) { '' }

        it 'have an error' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:calls, :blank)).to be(true)
        end
      end

      context 'is zero' do
        let(:calls) { 0 }

        it { expect(subject).to be_valid }
      end

      context 'is positive' do
        let(:calls) { 1 }

        it { expect(subject).to be_valid }
      end
    end

    describe '#letters_uplift' do
      context 'when apply_uplift is true' do
        context 'is negative' do
          let(:letters_uplift) { -1 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_uplift, :greater_than_or_equal_to)).to be(true)
          end
        end

        context 'is blank' do
          let(:letters_uplift) { '' }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_uplift, :blank)).to be(true)
          end
        end

        context 'is zero' do
          let(:letters_uplift) { 0 }

          it { expect(subject).to be_valid }
        end

        context 'is positive' do
          let(:letters_uplift) { 1 }

          it { expect(subject).to be_valid }
        end

        context 'is 100' do
          let(:letters_uplift) { 100 }

          it { expect(subject).to be_valid }
        end

        context 'is over 100' do
          let(:letters_uplift) { 101 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_uplift, :less_than_or_equal_to)).to be(true)
          end
        end

        context 'is not an integer'  do
          let(:letters_uplift) { 1.6 }

          it 'casts the value to abn integer' do
            expect(subject).to be_valid
            expect(subject.letters_uplift).to eq(1)
          end
        end
      end

      context 'when apply_letters_uplift is falsey' do
        let(:apply_letters_uplift) { 'false' }

        context 'is negative' do
          let(:letters_uplift) { -1 }

          it { expect(subject).to be_valid }
        end
      end
    end

    describe '#calls_uplift' do
      context 'when apply_uplift is true' do
        context 'is negative' do
          let(:calls_uplift) { -1 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:calls_uplift, :greater_than_or_equal_to)).to be(true)
          end
        end

        context 'is blank' do
          let(:calls_uplift) { '' }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:calls_uplift, :blank)).to be(true)
          end
        end

        context 'is zero' do
          let(:calls_uplift) { 0 }

          it { expect(subject).to be_valid }
        end

        context 'is positive' do
          let(:calls_uplift) { 1 }

          it { expect(subject).to be_valid }
        end

        context 'is 100' do
          let(:calls_uplift) { 100 }

          it { expect(subject).to be_valid }
        end

        context 'is over 100' do
          let(:calls_uplift) { 101 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:calls_uplift, :less_than_or_equal_to)).to be(true)
          end
        end

        context 'is not an integer' do
          let(:calls_uplift) { 1.6 }

          it 'casts the value to abn integer' do
            expect(subject).to be_valid
            expect(subject.calls_uplift).to eq(1)
          end
        end
      end

      context 'when apply_letters_uplift is falsey' do
        let(:apply_calls_uplift) { 'false' }

        context 'is negative' do
          let(:calls_uplift) { -1 }

          it { expect(subject).to be_valid }
        end
      end
    end
  end

  describe '#allow_uplift?' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      it { expect(subject).to be_allow_uplift }
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject).not_to be_allow_uplift }
    end
  end

  describe '#apply_letters_uplift' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      context 'when set to nil - not set' do
        let(:apply_letters_uplift) { nil }

        context 'and letters_calls_uplift is not nil' do
          let(:letters_uplift) { 10 }

          it { expect(subject.apply_letters_uplift).to be_truthy }
        end

        context 'and letters_calls_uplift is nil' do
          let(:letters_uplift) { nil }

          it { expect(subject.apply_letters_uplift).to be_falsey }
        end
      end

      context 'when set to "true"' do
        let(:apply_letters_uplift) { 'true' }

        it { expect(subject.apply_letters_uplift).to be_truthy }
      end

      context 'when set to "false"' do
        let(:apply_letters_uplift) { 'false' }

        it { expect(subject.apply_letters_uplift).to be_falsey }
      end
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject.apply_letters_uplift).to be_falsey }
    end
  end

  describe '#apply_calls_uplift' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      context 'when set to nil - not set' do
        let(:apply_calls_uplift) { nil }

        context 'and calls_uplift is not nil' do
          let(:calls_uplift) { 10 }

          it { expect(subject.apply_calls_uplift).to be_truthy }
        end

        context 'and letters_calls_uplift is nil' do
          let(:calls_uplift) { nil }

          it { expect(subject.apply_calls_uplift).to be_falsey }
        end
      end

      context 'when set to "true"' do
        let(:apply_calls_uplift) { 'true' }

        it { expect(subject.apply_calls_uplift).to be_truthy }
      end

      context 'when set to "false"' do
        let(:apply_calls_uplift) { 'false' }

        it { expect(subject.apply_calls_uplift).to be_falsey }
      end
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject.apply_calls_uplift).to be_falsey }
    end
  end

  describe 'calculation_rows' do
    context 'when values are nil' do
      let(:letters) { nil }
      let(:calls) { nil }

      it 'returns 0 values' do
        expect(subject.calculation_rows).to eq(
          [['Items', 'Before uplift', 'After uplift'],
           ['Letters',
            { html_attributes: { id: 'letters-without-uplift' }, text: '£' },
            { html_attributes: { id: 'letters-with-uplift' }, text: '£' }],
           ['Phone calls',
            { html_attributes: { id: 'calls-without-uplift' }, text: '£' },
            { html_attributes: { id: 'calls-with-uplift' }, text: '£' }]]
        )
      end
    end

    context 'when values are non-nil' do
      let(:letters) { 2 }
      let(:letters_uplift) { 10 }
      let(:calls_uplift) { 20 }

      context 'when uplift is not required' do
        let(:apply_letters_uplift) { 'false' }
        let(:apply_calls_uplift) { 'false' }

        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Items', 'Before uplift', 'After uplift'],
             ['Letters',
              { html_attributes: { id: 'letters-without-uplift' }, text: '£8.18' },
              { html_attributes: { id: 'letters-with-uplift' }, text: '£8.18' }],
             ['Phone calls',
              { html_attributes: { id: 'calls-without-uplift' }, text: '£4.09' },
              { html_attributes: { id: 'calls-with-uplift' }, text: '£4.09' }]]
          )
        end
      end

      context 'when uplift is required but values are not set' do
        let(:letters_uplift) { nil }
        let(:calls_uplift) { nil }

        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Items', 'Before uplift', 'After uplift'],
             ['Letters',
              { html_attributes: { id: 'letters-without-uplift' }, text: '£8.18' },
              { html_attributes: { id: 'letters-with-uplift' }, text: '£8.18' }],
             ['Phone calls',
              { html_attributes: { id: 'calls-without-uplift' }, text: '£4.09' },
              { html_attributes: { id: 'calls-with-uplift' }, text: '£4.09' }]]
          )
        end
      end

      context 'when uplift is required and values are not set' do
        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Items', 'Before uplift', 'After uplift'],
             ['Letters',
              { html_attributes: { id: 'letters-without-uplift' }, text: '£8.18' },
              { html_attributes: { id: 'letters-with-uplift' }, text: '£9.00' }],
             ['Phone calls',
              { html_attributes: { id: 'calls-without-uplift' }, text: '£4.09' },
              { html_attributes: { id: 'calls-with-uplift' }, text: '£4.91' }]]
          )
        end
      end
    end
  end

  describe 'save!' do
    context 'when letters_calls_uplift exists in DB but apply_uplift is false in attributes' do
      let(:apply_uplift) { 'false' }
      let(:application) do
        Claim.create(office_code: 'AAA', letters_uplift: 10, calls_uplift: 10, letters: letters, calls: calls)
      end

      it 'resets the letters_uplift and calls_uplift value' do
        subject.save!
        expect(application.reload).to have_attributes(
          letters_uplift: nil,
          calls_uplift: nil,
        )
      end
    end
  end
end
