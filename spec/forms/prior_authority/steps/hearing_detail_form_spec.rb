require 'rails_helper'

RSpec.describe PriorAuthority::Steps::HearingDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      **hearing_detail_attributes
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with hearing details' do
      let(:hearing_detail_attributes) do
        {
          next_hearing_date: Date.tomorrow,
          plea: 'not_guilty',
          court_type: 'central_criminal_court',
        }
      end

      it { is_expected.to be_valid }
    end

    context 'with invalid solicitor and firm details' do
      let(:hearing_detail_attributes) do
        {
          next_hearing_date: nil,
          plea: nil,
          court_type: nil,
        }
      end

      it 'has is a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.messages.values.flatten)
          .to include('Date cannot be blank',
                      'Select the likely or actual plea',
                      'Select the type of court')
      end
    end

    describe '#save' do
      subject(:save) { form.save }

      let(:application) { create(:prior_authority_application) }

      context 'with valid hearing details' do
        let(:hearing_detail_attributes) do
          {
            next_hearing_date: Date.tomorrow,
            plea: 'not_guilty',
            court_type: 'central_criminal_court',
          }
        end

        it 'persists the case details' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'next_hearing_date' => nil,
                'plea' => nil,
                'court_type' => nil,
              )
            )
            .to(
              hash_including(
                'next_hearing_date' => Date.tomorrow,
                'plea' => 'not_guilty',
                'court_type' => 'central_criminal_court',
              )
            )
        end
      end

      context 'with incomplete hearing details' do
        let(:hearing_detail_attributes) do
          {
            next_hearing_date: nil,
            plea: nil,
            court_type: nil,
          }
        end

        it 'does not persist the case details' do
          expect { save }.not_to change { application.reload.attributes }
            .from(
              hash_including(
                'next_hearing_date' => nil,
                'plea' => nil,
                'court_type' => nil,
              )
            )
        end
      end
    end
  end
end
