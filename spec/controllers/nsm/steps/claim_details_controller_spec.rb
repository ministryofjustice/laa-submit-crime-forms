require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::ClaimDetailsForm, Decisions::NsmDecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::ClaimDetailsForm
end
