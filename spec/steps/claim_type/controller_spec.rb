require 'rails_helper'

RSpec.describe Steps::ClaimTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::ClaimTypeForm, Decisions::SimpleDecisionTree
end
