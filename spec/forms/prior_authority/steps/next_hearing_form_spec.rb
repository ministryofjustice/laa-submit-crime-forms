require 'rails_helper'

RSpec.describe PriorAuthority::Steps::NextHearingForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      **next_hearing_attributes
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with next hearing details' do
      let(:next_hearing_attributes) do
        {
          next_hearing: true,
          next_hearing_date: Date.tomorrow,
        }
      end

      it { is_expected.to be_valid }
    end

    context 'with invalid next hearing details' do
      let(:next_hearing_attributes) do
        {
          next_hearing: nil,
          next_hearing_date: nil,
        }
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.messages.values.flatten)
          .to contain_exactly('Select yes if you know the date of the next hearing')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid next hearing details' do
      let(:next_hearing_attributes) do
        {
          next_hearing: true,
          next_hearing_date: Date.tomorrow,
        }
      end

      it 'persists the next hearing details' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'next_hearing' => nil,
              'next_hearing_date' => nil,
            )
          )
          .to(
            hash_including(
              'next_hearing' => true,
              'next_hearing_date' => Date.tomorrow,
            )
          )
      end
    end

    context 'with incomplete next hearing details' do
      let(:next_hearing_attributes) do
        {
          next_hearing: true,
          next_hearing_date: nil,
        }
      end

      it 'does not persist the next hearing details' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'next_hearing' => nil,
              'next_hearing_date' => nil,
            )
          )
      end
    end

    context 'when answer changed from yes to no' do
      let(:application) { create(:prior_authority_application, next_hearing: true, next_hearing_date: a_date) }
      let(:a_date) { Date.tomorrow }

      let(:next_hearing_attributes) do
        {
          next_hearing: false,
          next_hearing_date: a_date,
        }
      end

      it 'nullifies next_hearing_date field' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'next_hearing' => true,
              'next_hearing_date' => a_date,
            )
          )
          .to(
            hash_including(
              'next_hearing' => false,
              'next_hearing_date' => nil,
            )
          )
      end
    end
  end
end
