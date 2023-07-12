require 'rails_helper'

RSpec.describe Steps::EqualityController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::AnswerEqualityForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AnswerEqualityForm
end
