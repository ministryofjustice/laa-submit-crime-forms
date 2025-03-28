require 'rails_helper'

RSpec.describe Claim do
  let(:claim) { described_class.new(attributes) }

  describe '#main_defendant' do
    let(:claim) { create(:claim, :main_defendant) }

    it 'returns the main defendant' do
      expect(claim.main_defendant).to eq claim.defendants.find_by(main: true)
    end
  end

  describe '#work_item_position' do
    let(:claim) { create(:claim, work_items:) }

    let(:work_items) { [work_item_a, work_item_b, work_item_c, work_item_d, work_item_e, work_item_f] }
    let(:work_item_a) { build(:work_item, :waiting, completed_on: 1.day.ago.to_date) }
    let(:work_item_b) { build(:work_item, :travel, completed_on: 1.day.ago.to_date) }
    let(:work_item_c) { build(:work_item, :attendance_with_counsel, completed_on: 2.days.ago.to_date) }
    let(:work_item_d) { build(:work_item, :attendance_without_counsel, completed_on: 2.days.ago.to_date) }
    let(:work_item_e) { build(:work_item, :advocacy, completed_on: 3.days.ago.to_date) }
    let(:work_item_f) { build(:work_item, :preparation, completed_on: 3.days.ago.to_date) }

    # sorting is by date asc, type asc (case insensitive) and created_at asc
    it 'returns 1-based index of work items after sorting by date asc, type asc and created_at asc' do
      sorted_positions = [
        claim.work_item_position(work_item_e),
        claim.work_item_position(work_item_f),
        claim.work_item_position(work_item_c),
        claim.work_item_position(work_item_d),
        claim.work_item_position(work_item_b),
        claim.work_item_position(work_item_a),
      ]

      expect(sorted_positions).to eql [1, 2, 3, 4, 5, 6]
    end

    context 'when one work item has no work type' do
      let(:work_items) { [work_item_a, work_item_b] }
      let(:work_item_a) { build(:work_item, :waiting, completed_on: 1.day.ago.to_date) }
      let(:work_item_b) { build(:work_item, work_type: nil, completed_on: 1.day.ago.to_date) }

      it 'returns sensible positions' do
        sorted_positions = [
          claim.work_item_position(work_item_b),
          claim.work_item_position(work_item_a),
        ]

        expect(sorted_positions).to eql [1, 2]
      end
    end
  end

  describe '#disbursement_position' do
    let(:claim) { create(:claim, disbursements:) }

    let(:disbursements) { [disbursement_a, disbursement_b, disbursement_c, disbursement_d, disbursement_e, disbursement_f] }
    let(:disbursement_a) { build(:disbursement, :valid_other, :dna_testing, age: 3) }
    let(:disbursement_b) { build(:disbursement, :valid, :bike, age: 5) }
    let(:disbursement_c) { build(:disbursement, :valid_other, :dna_testing, age: 4) }
    let(:disbursement_d) { build(:disbursement, :valid_other, other_type: 'testerization', age: 4) }
    let(:disbursement_e) { build(:disbursement, :valid_other, other_type: 'Witness', age: 4, created_at: 1.day.ago) }
    let(:disbursement_f) { build(:disbursement, :valid_other, other_type: 'witness', age: 4, created_at: 2.days.ago) }

    # sorting is by date asc, type asc (case insensitive) and created_at asc
    it 'returns 1-based index of disbursement after sorting by date asc, type asc (case insensitive) and created_at asc' do
      sorted_positions = [
        claim.disbursement_position(disbursement_b),
        claim.disbursement_position(disbursement_c),
        claim.disbursement_position(disbursement_d),
        claim.disbursement_position(disbursement_f),
        claim.disbursement_position(disbursement_e),
        claim.disbursement_position(disbursement_a),
      ]

      expect(sorted_positions).to eql [1, 2, 3, 4, 5, 6]
    end
  end

  describe '#update_work_item_positions!' do
    let(:claim) { create(:claim, work_items:) }

    let(:work_items) { [work_item_a, work_item_b, work_item_c, work_item_d, work_item_e, work_item_f] }
    let(:work_item_a) { build(:work_item, :waiting, completed_on: 1.day.ago.to_date) }
    let(:work_item_b) { build(:work_item, :travel, completed_on: 1.day.ago.to_date) }
    let(:work_item_c) { build(:work_item, :attendance_with_counsel, completed_on: 2.days.ago.to_date) }
    let(:work_item_d) { build(:work_item, :attendance_without_counsel, completed_on: 2.days.ago.to_date) }
    let(:work_item_e) { build(:work_item, :advocacy, completed_on: 3.days.ago.to_date) }
    let(:work_item_f) { build(:work_item, :preparation, completed_on: 3.days.ago.to_date) }

    it 'updates all workitem position database values from nil' do
      expect { claim.update_work_item_positions! }
        .to change { claim.work_items.where.not(position: nil).count }
        .from(0)
        .to(6)
    end

    it 'updates all work item position database values to their expected value' do
      claim.update_work_item_positions!

      # read the database attribute value, not position method's call result
      expect(work_item_e.reload.read_attribute(:position)).to be 1
      expect(work_item_f.reload.read_attribute(:position)).to be 2
      expect(work_item_c.reload.read_attribute(:position)).to be 3
      expect(work_item_d.reload.read_attribute(:position)).to be 4
      expect(work_item_b.reload.read_attribute(:position)).to be 5
      expect(work_item_a.reload.read_attribute(:position)).to be 6
    end
  end

  describe '#update_disbursement_position!' do
    let(:claim) { create(:claim, disbursements:) }

    let(:disbursements) { [disbursement_a, disbursement_b, disbursement_c, disbursement_d, disbursement_e, disbursement_f] }
    let(:disbursement_a) { build(:disbursement, :valid_other, :dna_testing, age: 3) }
    let(:disbursement_b) { build(:disbursement, :valid, :bike, age: 5) }
    let(:disbursement_c) { build(:disbursement, :valid_other, :dna_testing, age: 4) }
    let(:disbursement_d) { build(:disbursement, :valid_other, other_type: 'testerization', age: 4) }
    let(:disbursement_e) { build(:disbursement, :valid_other, other_type: 'Witness', age: 4, created_at: 1.day.ago) }
    let(:disbursement_f) { build(:disbursement, :valid_other, other_type: 'witness', age: 4, created_at: 2.days.ago) }

    it 'updates all disbursement position database values from nil' do
      expect { claim.update_disbursement_positions! }
        .to change { claim.disbursements.where.not(position: nil).count }
        .from(0)
        .to(6)
    end

    it 'updates all disbursement position database values to their expected value' do
      claim.update_disbursement_positions!

      # read the database attribute value, not position method's call result
      expect(disbursement_b.reload.read_attribute(:position)).to be 1
      expect(disbursement_c.reload.read_attribute(:position)).to be 2
      expect(disbursement_d.reload.read_attribute(:position)).to be 3
      expect(disbursement_f.reload.read_attribute(:position)).to be 4
      expect(disbursement_e.reload.read_attribute(:position)).to be 5
      expect(disbursement_a.reload.read_attribute(:position)).to be 6
    end
  end

  describe '#destroy_attachments' do
    let(:test_file_path) { 'test_path' }
    let(:file_evidence) { double('file_evidence', file_path: test_file_path) }

    before do
      allow(claim).to receive(:supporting_evidence).and_return([file_evidence])
    end

    context 'when claim is a draft' do
      let(:claim) { create(:claim, :complete, :as_draft) }

      it 'removes attachments for drafts' do
        allow_any_instance_of(FileUpload::FileUploader).to receive(:exists?).with(test_file_path).and_return(true)
        expect_any_instance_of(FileUpload::FileUploader).to receive(:destroy).with(test_file_path).at_least(:once)
        claim.destroy
      end

      it 'does not attempt to remove files that do not exist' do
        allow_any_instance_of(FileUpload::FileUploader).to receive(:exists?).with(test_file_path).and_return(false)
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)
        claim.destroy
      end
    end

    context 'when claim is not a draft' do
      let(:claim) { create(:claim, :complete, :as_submitted) }

      it 'does not remove attachments for non-drafts' do
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:exists?)
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)
        claim.destroy
      end
    end
  end
end
