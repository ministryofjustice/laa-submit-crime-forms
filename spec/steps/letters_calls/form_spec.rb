require 'rails_helper'

RSpec.describe Steps::LettersCallsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      letters:,
      calls:,
      apply_uplift:,
      letters_calls_uplift:,
    }
  end

  let(:application) { instance_double(Claim, update!: true, date: date, reasons_for_claim: reasons_for_claim) }
  let(:letters) { 1 }
  let(:calls) { 1 }
  let(:apply_uplift) { 'true' }
  let(:letters_calls_uplift) { 0 }
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

    describe '#letters_calls_uplift' do
      context 'when apply_uplift is true' do
        context 'is negative' do
          let(:letters_calls_uplift) { -1 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_calls_uplift, :greater_than_or_equal_to)).to be(true)
          end
        end

        context 'is blank' do
          let(:letters_calls_uplift) { '' }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_calls_uplift, :blank)).to be(true)
          end
        end

        context 'is zero' do
          let(:letters_calls_uplift) { 0 }

          it { expect(subject).to be_valid }
        end

        context 'is positive' do
          let(:letters_calls_uplift) { 1 }

          it { expect(subject).to be_valid }
        end

        context 'is 100' do
          let(:letters_calls_uplift) { 100 }

          it { expect(subject).to be_valid }
        end

        context 'is over 100' do
          let(:letters_calls_uplift) { 101 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:letters_calls_uplift, :less_than_or_equal_to)).to be(true)
          end
        end

        context 'is not an integer'  do
          let(:letters_calls_uplift) { 1.6 }

          it 'casts the value to abn integer' do
            expect(subject).to be_valid
            expect(subject.letters_calls_uplift).to eq(1)
          end
        end
      end

      context 'when apply_uplift is falsey' do
        let(:apply_uplift) { 'false' }

        context 'is negative' do
          let(:letters_calls_uplift) { -1 }

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

  describe '#apply_uplift' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      context 'when set to nil - not set' do
        let(:apply_uplift) { nil }

        context 'and letters_calls_uplift is not nil' do
          let(:letters_calls_uplift) { 10 }

          it { expect(subject.apply_uplift).to be_truthy }
        end

        context 'and letters_calls_uplift is nil' do
          let(:letters_calls_uplift) { nil }

          it { expect(subject.apply_uplift).to be_falsey }
        end
      end

      context 'when set to "true"' do
        let(:apply_uplift) { 'true' }

        it { expect(subject.apply_uplift).to be_truthy }
      end

      context 'when set to "false"' do
        let(:apply_uplift) { 'false' }

        it { expect(subject.apply_uplift).to be_falsey }
      end
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject.apply_uplift).to be_falsey }
    end
  end

  describe '#letters_total' do
    let(:date) { Date.new(2022, 9, 30) }
    let(:letters) { 2 }
    let(:letters_calls_uplift) { nil }

    context 'when date is not set' do
      let(:date) { nil }

      it { expect(subject.letters_total).to eq(2.0 * 4.09 * 1) }
    end

    context 'when date is before 30 Sep 2022' do
      let(:date) { Date.new(2022, 9, 29) }

      it { expect(subject.letters_total).to eq(2.0 * 3.56 * 1) }
    end

    context 'when date is on or after 30 Sep 2022' do
      it { expect(subject.letters_total).to eq(2.0 * 4.09 * 1) }
    end

    context 'when uplift is set' do
      let(:letters_calls_uplift) { 10 }

      it { expect(subject.letters_total).to eq(2.0 * 4.09 * 1.1) }
    end

    context 'when letters is 0' do
      let(:letters) { 0 }

      it { expect(subject.letters_total).to eq(0.0 * 4.09 * 1) }
    end
  end

  describe '#calls_total' do
    let(:date) { Date.new(2022, 9, 30) }
    let(:calls) { 2 }
    let(:letters_calls_uplift) { nil }

    context 'when date is not set' do
      let(:date) { nil }

      it { expect(subject.calls_total).to eq(2.0 * 4.09 * 1) }
    end

    context 'when date is before 30 Sep 2022' do
      let(:date) { Date.new(2022, 9, 29) }

      it { expect(subject.calls_total).to eq(2.0 * 3.56 * 1) }
    end

    context 'when date is on or after 30 Sep 2022' do
      it { expect(subject.calls_total).to eq(2.0 * 4.09 * 1) }
    end

    context 'when uplift is set' do
      let(:letters_calls_uplift) { 10 }

      it { expect(subject.calls_total).to eq(2.0 * 4.09 * 1.1) }
    end

    context 'when calls is 0' do
      let(:calls) { 0 }

      it { expect(subject.calls_total).to eq(0.0 * 4.09 * 1) }
    end
  end

  describe '#total_cost' do
    let(:date) { Date.new(2022, 9, 30) }
    let(:letters) { 2 }
    let(:calls) { 3 }
    let(:letters_calls_uplift) { nil }

    context 'when date is not set' do
      let(:date) { nil }

      it { expect(subject.total_cost).to eq(5.0 * 4.09 * 1) }
    end

    context 'when date is before 30 Sep 2022' do
      let(:date) { Date.new(2022, 9, 29) }

      it { expect(subject.total_cost).to eq(5.0 * 3.56 * 1) }
    end

    context 'when date is on or after 30 Sep 2022' do
      it { expect(subject.total_cost).to eq(5.0 * 4.09 * 1) }
    end

    context 'when uplift is set' do
      let(:letters_calls_uplift) { 10 }

      it { expect(subject.total_cost).to eq(5.0 * 4.09 * 1.1) }
    end

    context 'when letters is 0' do
      let(:letters) { 0 }

      it { expect(subject.total_cost).to eq(3.0 * 4.09 * 1) }
    end

    context 'when calls is 0' do
      let(:calls) { 0 }

      it { expect(subject.total_cost).to eq(2.0 * 4.09 * 1) }
    end
  end

  describe 'save!' do
    context 'when letters_calls_uplift exists in DB but apply_uplift is false in attributes' do
      let(:apply_uplift) { 'false' }
      let(:application) { Claim.create(office_code: 'AAA', letters_calls_uplift: 10, letters: letters, calls: calls) }

      it 'resets the letters_calls_uplift value' do
        subject.save!
        expect(application.reload).to have_attributes(
          letters_calls_uplift: nil
        )
      end
    end
  end
end
