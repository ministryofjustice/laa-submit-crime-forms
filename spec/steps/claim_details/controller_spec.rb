require 'rails_helper'

RSpec.describe Steps::ClaimDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::ClaimDetailsForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::ClaimDetailsForm
end
