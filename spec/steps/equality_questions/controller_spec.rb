require 'rails_helper'

RSpec.describe Steps::EqualityQuestionsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::EqualityQuestionsForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::EqualityQuestionsForm
end
