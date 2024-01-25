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

        it 'persists the hearing details' do
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

        it 'does not persist the hearing details' do
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

      context 'when changing court type from magistrates to central criminal court' do
        let(:application) { create(:prior_authority_application, :with_youth_court) }

        let(:hearing_detail_attributes) do
          {
            next_hearing_date: Date.tomorrow,
            plea: 'not_guilty',
            court_type: 'central_criminal_court',
          }
        end

        it 'nullifies youth_court attribute' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'court_type' => 'magistrates_court',
                'youth_court' => true,
              )
            )
            .to(
              hash_including(
                'court_type' => 'central_criminal_court',
                'youth_court' => nil,
              )
            )
        end
      end

      context 'when changing court type from central criminal to magistrates courts' do
        let(:application) { create(:prior_authority_application, :with_psychiatric_liaison) }

        let(:hearing_detail_attributes) do
          {
            next_hearing_date: Date.tomorrow,
            plea: 'not_guilty',
            court_type: 'magistrates_court',
          }
        end

        it 'nullifies psychiatric_liaison attributes' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'court_type' => 'central_criminal_court',
                'psychiatric_liaison' => false,
                'psychiatric_liaison_reason_not' => 'whatever you like',
              )
            )
            .to(
              hash_including(
                'court_type' => 'magistrates_court',
                'psychiatric_liaison' => nil,
                'psychiatric_liaison_reason_not' => nil,
              )
            )
        end
      end

      context 'when changing court type from central criminal to crown court' do
        let(:application) { create(:prior_authority_application, :with_psychiatric_liaison) }

        let(:hearing_detail_attributes) do
          {
            next_hearing_date: Date.tomorrow,
            plea: 'not_guilty',
            court_type: 'crown_court',
          }
        end

        it 'nullifies psychiatric_liaison attributes' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'court_type' => 'central_criminal_court',
                'psychiatric_liaison' => false,
                'psychiatric_liaison_reason_not' => 'whatever you like',
              )
            )
            .to(
              hash_including(
                'court_type' => 'crown_court',
                'psychiatric_liaison' => nil,
                'psychiatric_liaison_reason_not' => nil,
              )
            )
        end
      end

      context 'when changing court type from magistrates to crown court' do
        let(:application) { create(:prior_authority_application, :with_youth_court) }

        let(:hearing_detail_attributes) do
          {
            next_hearing_date: Date.tomorrow,
            plea: 'not_guilty',
            court_type: 'crown_court',
          }
        end

        it 'nullifies youth_court attribute' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'court_type' => 'magistrates_court',
                'youth_court' => true,
              )
            )
            .to(
              hash_including(
                'court_type' => 'crown_court',
                'youth_court' => nil,
              )
            )
        end
      end
    end
  end
end
