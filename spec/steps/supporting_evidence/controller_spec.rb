require 'rails_helper'

RSpec.describe Steps::SupportingEvidenceController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::SupportingEvidenceForm, Decisions::SimpleDecisionTree

  it_behaves_like 'a step that can be drafted', Steps::SupportingEvidenceForm
end
