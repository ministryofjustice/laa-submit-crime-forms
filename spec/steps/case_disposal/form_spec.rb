require 'rails_helper'

RSpec.describe Steps::CaseDisposalForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      plea:,
      arrest_warrent_date:,
      cracked_trial_date:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:plea) { nil }
  let(:arrest_warrent_date) { nil }
  let(:cracked_trial_date) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq(
        guilty_pleas: PleaOptions::GUILTY_OPTIONS,
        not_guilty_pleas: PleaOptions::NOT_GUILTY_OPTIONS
      )
    end
  end

  describe '#save' do
    context 'when `plea` is not provided' do
      it { expect(subject.save).to be(false) }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when `plea` is not valid' do
      let(:plea) { 'maybe' }

      it { expect(subject.save).to be(false) }

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when `plea` is valid' do
      PleaOptions.values.each do |plea_inst|
        context 'and does not require a date field' do
          next if plea_inst.requires_date_field?

          let(:plea) { plea_inst }

          it "updates the record for #{plea_inst}" do
            expect(subject.save).to be_truthy
            expect(application).to have_received(:update!).with(
              'plea' => plea_inst,
              'arrest_warrent_date' => nil,
              'cracked_trial_date' => nil,
            )
          end

          context 'but date field passed in anyway' do
            let(:arrest_warrent_date) { Date.yesterday }

            it 'will ignore date field' do
              expect(subject.save).to be_truthy
              expect(application).to have_received(:update!).with(
                'plea' => plea_inst,
                'arrest_warrent_date' => nil,
                'cracked_trial_date' => nil,
              )
            end
          end
        end

        context 'and requires a date field' do
          next unless plea_inst.requires_date_field?

          let(:plea) { plea_inst }
          let(:date_field) { "#{plea.value}_date" }

          context 'when date is in the future' do
            let(:"#{plea_inst.value}_date") { Date.tomorrow }

            it 'returns false' do
              expect(subject.save).to be(false)
            end

            it 'has a validation error on the field' do
              expect(subject).not_to be_valid
              expect(subject.errors.of_kind?(date_field, :future_not_allowed)).to be(true)
            end
          end

          context 'when date is today' do
            let(:"#{plea_inst.value}_date") { Time.zone.today }

            it "updates the record for #{plea_inst}" do
              expect(subject.save).to be_truthy
              expect(application).to have_received(:update!).with(
                'plea' => plea,
                'arrest_warrent_date' => arrest_warrent_date,
                'cracked_trial_date' => cracked_trial_date
              )
            end
          end

          context 'when date is in the past' do
            let(:"#{plea_inst.value}_date") { Date.yesterday }

            it "updates the record for #{plea_inst}" do
              expect(subject.save).to be_truthy
              expect(application).to have_received(:update!).with(
                'plea' => plea,
                'arrest_warrent_date' => arrest_warrent_date,
                'cracked_trial_date' => cracked_trial_date
              )
            end
          end
        end
      end
    end
  end
end
