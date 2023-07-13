require 'rails_helper'

RSpec.describe Tasks::SolicitorDeclaration, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.create(attributes) }
  let(:attributes) { { id: id, office_code: 'AAA' } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/solicitor_declaration") }
  end

  it_behaves_like 'a task with generic complete?', Steps::SolicitorDeclarationForm
end
