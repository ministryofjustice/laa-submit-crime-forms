require 'rails_helper'

RSpec.describe Nsm::Steps::EqualityController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::AnswerEqualityForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::AnswerEqualityForm
end
