require 'rails_helper'

RSpec.describe Nsm::Steps::CaseDisposalController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::CaseDisposalForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::CaseDisposalForm
end
