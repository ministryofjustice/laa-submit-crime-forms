require 'rails_helper'

RSpec.describe Steps::CaseDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::CaseDetailsForm, Decisions::DecisionTree
end
