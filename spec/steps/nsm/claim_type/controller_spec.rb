require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::ClaimTypeForm, Decisions::DecisionTree
end
