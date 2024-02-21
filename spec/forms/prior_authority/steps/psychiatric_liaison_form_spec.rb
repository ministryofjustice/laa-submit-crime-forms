require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PsychiatricLiaisonForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      psychiatric_liaison:,
      psychiatric_liaison_reason_not:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with psychiatric liaison value of true and no reason given' do
      let(:psychiatric_liaison) { 'true' }
      let(:psychiatric_liaison_reason_not) { '' }

      it { is_expected.to be_valid }
    end

    context 'with psychiatric liaison value of false and reason given' do
      let(:psychiatric_liaison) { 'true' }
      let(:psychiatric_liaison_reason_not) { 'whatever' }

      it { is_expected.to be_valid }
    end

    context 'with blank psychiatric liaison' do
      let(:psychiatric_liaison) { '' }
      let(:psychiatric_liaison_reason_not) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:psychiatric_liaison, :inclusion)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to contain_exactly('Select yes if you have accessed the psychiatric liason service')
      end
    end

    context 'with psychiatric liaison false and no reason given' do
      let(:psychiatric_liaison) { 'false' }
      let(:psychiatric_liaison_reason_not) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:psychiatric_liaison_reason_not, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to contain_exactly('Explain why you did not access the psychiatric liaison service')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with psychiatric liaison of true and no reason given' do
      let(:psychiatric_liaison) { 'true' }
      let(:psychiatric_liaison_reason_not) { '' }

      it 'persists the value' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'psychiatric_liaison' => nil,
              'psychiatric_liaison_reason_not' => nil,
            )
          )
          .to(
            hash_including(
              'psychiatric_liaison' => true,
              'psychiatric_liaison_reason_not' => nil,
            )
          )
      end
    end

    context 'with psychiatric liaison of false and reason given' do
      let(:psychiatric_liaison) { 'false' }
      let(:psychiatric_liaison_reason_not) { 'whatever' }

      it 'persists the value' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'psychiatric_liaison' => nil,
              'psychiatric_liaison_reason_not' => nil,
            )
          )
          .to(
            hash_including(
              'psychiatric_liaison' => false,
              'psychiatric_liaison_reason_not' => 'whatever',
            )
          )
      end
    end

    context 'with blank psychiatric liaison value' do
      let(:psychiatric_liaison) { '' }
      let(:psychiatric_liaison_reason_not) { '' }

      it 'does not persists the psychiatric liaison value' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'psychiatric_liaison' => nil,
              'psychiatric_liaison_reason_not' => nil,
            )
          )
      end

      context 'when psychiatric liaison of false with reason changed to true' do
        let(:application) do
          create(:prior_authority_application,
                 psychiatric_liaison: false,
                 psychiatric_liaison_reason_not: 'whatever')
        end

        let(:psychiatric_liaison) { 'true' }

        it 'blanks the reason not value' do
          expect { save }.to change { application.reload.attributes }
            .from(
              hash_including(
                'psychiatric_liaison' => false,
                'psychiatric_liaison_reason_not' => 'whatever',
              )
            )
            .to(
              hash_including(
                'psychiatric_liaison' => true,
                'psychiatric_liaison_reason_not' => nil,
              )
            )
        end
      end
    end
  end
end
