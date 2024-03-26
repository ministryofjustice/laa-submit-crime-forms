require 'rails_helper'

RSpec.describe PriorAuthority::Steps::FurtherInformationForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      information_supplied:
    }
  end

  let(:record) { instance_double(FurtherInformation) }

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with information supplied' do
      let(:information_supplied) { 'some information' }

      it { is_expected.to be_valid }
    end

    context 'with blank information supplied' do
      let(:information_supplied) { '' }
      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:information_supplied, :blank)).to be(true)
        expect(form.errors.messages[:information_supplied]).to include('Enter the requested information')
      end
    end
  end

  # describe '#save' do
  #   subject(:save) { form.save }

  #   let(:application) { create(:prior_authority_application) }

  #   context 'with a valid reason why' do
  #     let(:further_information) {
  #       {
  #         information_supplied: 'some information'
  #       }
  #     }

  #     it 'persists the reason why' do
  #       expect { save }.to change { application.reload.reason_why }.from(nil).to('important_stuff')
  #     end
  #   end
  # end
end
