require 'rails_helper'

RSpec.describe Steps::SolicitorDeclarationController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::SolicitorDeclarationForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::SolicitorDeclarationForm
end
