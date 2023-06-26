require 'rails_helper'

RSpec.describe Pricing do
  subject { described_class.for(application) }

  let(:application) { double(:application, date:) }
  let(:date) { nil }

  describe '#for' do
    context 'when date is nil' do
      it 'returns the current (post CLAIR) pricing' do
        expect(described_class).to receive(:new).with(
          {
            'preparation' => 52.15,
            'advocacy' => 65.42,
            'attendance_with_counsel' => 35.68,
            'attendance_without_counsel' => 35.68,
            'travel' => 27.60,
            'waiting' => 27.60,
            'letters' => 4.09,
            'calls' => 4.09,
            'car' => 0.45,
            'motorcycle' => 0.45,
            'bike' => 0.25,
          }
        )
        subject
      end
    end

    context 'when date is after 29 Sep 2022' do
      let(:date) { Date.new(2022, 9, 30) }

      it 'returns the current (post CLAIR) pricing' do
        expect(described_class).to receive(:new).with(
          {
            'preparation' => 52.15,
            'advocacy' => 65.42,
            'attendance_with_counsel' => 35.68,
            'attendance_without_counsel' => 35.68,
            'travel' => 27.60,
            'waiting' => 27.60,
            'letters' => 4.09,
            'calls' => 4.09,
            'car' => 0.45,
            'motorcycle' => 0.45,
            'bike' => 0.25,
          }
        )
        subject
      end
    end

    context 'when date is before 30 Spe 2022' do
      let(:date) { Date.new(2022, 9, 29) }

      it 'returns the old (pre CLAIR) pricing' do
        expect(described_class).to receive(:new).with(
          {
            'preparation' => 45.35,
            'advocacy' => 56.89,
            'attendance_with_counsel' => 31.03,
            'attendance_without_counsel' => 31.03,
            'travel' => 24.0,
            'waiting' => 24.0,
            'letters' => 3.56,
            'calls' => 3.56,
            'car' => 0.45,
            'motorcycle' => 0.45,
            'bike' => 0.25,
          }
        )
        subject
      end
    end
  end

  describe 'accessing field' do
    Pricing::FIELDS.each do |field|
      context "when #{field}" do
        it 'can be access via method call' do
          expect(subject.public_send(field).to_f).not_to eq(0.0)
        end

        it 'can be access via [] syntax' do
          expect(subject[field].to_f).not_to eq(0.0)
        end

        it 'returns the same value regardless of access method' do
          expect(subject.public_send(field).to_f).to eq(subject[field].to_f)
        end
      end
    end
  end
end
