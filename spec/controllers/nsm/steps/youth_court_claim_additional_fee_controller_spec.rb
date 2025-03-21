require 'rails_helper'

RSpec.describe Nsm::Steps::YouthCourtClaimAdditionalFeeController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::YouthCourtClaimAdditionalFeeForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::YouthCourtClaimAdditionalFeeForm
end
