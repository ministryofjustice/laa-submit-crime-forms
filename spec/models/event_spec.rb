require 'rails_helper'

RSpec.describe Event do
  describe '#as_json' do
    it 'generates the desired JSON' do
      event = create(:event, :new_version)
      expect(event.as_json).to match(
        'claim_version' => 1,
        'created_at' => an_instance_of(String),
        'details' => {},
        'linked_id' => nil,
        'linked_type' => nil,
        'primary_user_id' => nil,
        'public' => nil,
        'secondary_user_id' => nil,
        'updated_at' => an_instance_of(String),
        :event_type => 'Event::NewVersion',
        :public => false,
      )
    end

    context 'when event_type is public' do
      it 'generates the desired public JSON' do
        event = create(:event, :decision)

        expect(event.as_json).to match(
          'claim_version' => 1,
          'created_at' => an_instance_of(String),
          'details' => { 'from' => 'submitted', 'to' => 'granted' },
          'linked_id' => nil,
          'linked_type' => nil,
          'primary_user_id' => nil,
          'public' => nil,
          'secondary_user_id' => nil,
          'updated_at' => an_instance_of(String),
          :event_type => 'Event::Decision',
          :public => true,
        )
      end
    end
  end
end
