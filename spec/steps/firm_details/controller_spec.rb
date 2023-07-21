require 'rails_helper'

RSpec.describe Steps::FirmDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::FirmDetailsForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::FirmDetailsForm
end
