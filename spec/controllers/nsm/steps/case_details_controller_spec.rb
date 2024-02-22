require 'rails_helper'

RSpec.describe Nsm::Steps::CaseDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::CaseDetailsForm, Decisions::NsmDecisionTree
end
