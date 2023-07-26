require 'rails_helper'

RSpec.describe Steps::HearingDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::HearingDetailsForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::HearingDetailsForm
end
