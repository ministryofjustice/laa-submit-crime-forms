require 'rails_helper'

RSpec.describe Steps::LettersCallsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::LettersCallsForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::LettersCallsForm
end
