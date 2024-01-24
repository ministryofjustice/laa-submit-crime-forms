require 'rails_helper'

RSpec.describe Nsm::Steps::ReasonForClaimController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::ReasonForClaimForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::ReasonForClaimForm
end
