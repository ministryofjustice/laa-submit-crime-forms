require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ReasonWhyForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      reason_why:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with a reason_why' do
      let(:reason_why) { 'important stuff' }

      it { is_expected.to be_valid }
    end

    context 'with blank reason_why' do
      let(:reason_why) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:reason_why, :blank)).to be(true)
        expect(form.errors.messages[:reason_why]).to include('Enter why prior authority is required')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with a valid reason why' do
      let(:reason_why) { 'important_stuff' }

      it 'persists the reason why' do
        expect { save }.to change { application.reload.reason_why }.from(nil).to('important_stuff')
      end
    end
  end
end
