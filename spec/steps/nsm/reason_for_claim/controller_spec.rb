require 'rails_helper'

RSpec.describe Steps::ReasonForClaimController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::ReasonForClaimForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::ReasonForClaimForm
end
