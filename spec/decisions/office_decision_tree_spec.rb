require 'rails_helper'

RSpec.describe Decisions::OfficeDecisionTree do
  let(:id) { SecureRandom.uuid }
  let(:application) { build(:provider) }
  let(:record) { application }
  let(:form) { double(:form, application:, record:) }

  it_behaves_like 'a generic decision', from: :select_office, goto: { action: :index, controller: '/nsm/claims' }

  context 'answer yes to is_current_office' do
    before { allow(form).to receive(:is_current_office).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :confirm_office, goto: { action: :index, controller: '/nsm/claims' }
  end

  context 'answer no to is_current_office' do
    before { allow(form).to receive(:is_current_office).and_return(YesNoAnswer::NO) }

    it_behaves_like 'a generic decision', from: :confirm_office, goto: { action: :edit, controller: '/nsm/steps/office/select' }
  end
end
