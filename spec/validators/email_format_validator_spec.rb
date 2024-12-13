require 'rails_helper'

RSpec.describe EmailFormatValidator do
  subject { klass.new(email:) }

  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      def self.name
        'EmailFormatTest'
      end
      attribute :email
      validates :email, email_format: true
    end
  end

  {
    'accepts standard email format' => 'user@example.com',
    'accepts email with dots in local part' => 'first.last@example.com',
    'accepts email with subdomain' => 'user@sub.domain.com',
    'accepts email with numbers' => 'user123@example.com',
    'accepts email with allowed special chars' => 'user+test@example.com'
  }.each do |description, email|
    context description do
      let(:email) { email }

      it { is_expected.to be_valid }
    end
  end

  {
    'rejects plain text' => 'John Smith',
    'rejects oversized local part' => "#{'a' * 320}@example.com",
    'rejects consecutive dots' => 'foo..bar@example.com',
    'rejects oversized domain' => "foo@#{'a' * 254}.com",
    'rejects missing TLD' => 'foo@domain',
    'rejects empty hostname' => 'foo@.co.uk',
    'rejects invalid hostname chars' => 'foo@f!oo.com',
    'rejects invalid TLD' => 'foo@bar.co.k',
    'rejects trailing dot' => 'foo@bar.co.uk.',
    'rejects multiple @ symbols' => 'foo@bar.co.uk@test',
    'rejects leading dot' => '.test@example.com'
  }.each do |description, email|
    context description do
      let(:email) { email }

      it { is_expected.not_to be_valid }
    end
  end
end
