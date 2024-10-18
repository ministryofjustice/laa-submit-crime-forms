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

  context 'when email is valid' do
    let(:email) { 'foo@example.com' }

    it { expect(subject).to be_valid }
  end

  context 'when value is not an email' do
    let(:email) { 'John Smith' }

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:email, :invalid)).to be(true)
    end
  end

  context 'when prefix is too long' do
    let(:email) { "#{'a' * 320}@example.com" }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has double dot' do
    let(:email) { 'foo..bar@example.com' }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has super long hostname' do
    let(:email) { "foo@#{'a' * 254}.com" }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has just one hostname part' do
    let(:email) { 'foo@domain' }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has super long domain' do
    let(:email) { "foo@#{'a' * 64}.com" }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has blank hostname part' do
    let(:email) { 'foo@.foo.com' }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has invalid hostname part' do
    let(:email) { 'foo@f!oo.com' }

    it { expect(subject).not_to be_valid }
  end

  context 'when email has invalid tld' do
    let(:email) { 'foo@bar.co.k' }

    it { expect(subject).not_to be_valid }
  end
end
