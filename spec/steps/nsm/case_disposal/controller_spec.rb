require 'rails_helper'

RSpec.describe Steps::CaseDisposalController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::CaseDisposalForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::CaseDisposalForm
end
