require 'rails_helper'

RSpec.describe SubmissionStatusUpdate do
  describe '#perform' do
    let(:aws_lambda_service_double) { double(trigger: true) }
    let(:submission_status_check) { SubmissionStatusUpdate.new(submission) }

    context 'given a "processing" submission' do
      context 'with "pending" entries' do
        let(:submission) { FactoryBot.create(:submission_with_pending_entries, aasm_state: :processing) }
        before { submission_status_check.perform! }

        it 'leaves the submission in a "processing" state' do
          expect(submission).to be_processing
        end

        it 'does not queue a management charge calculation' do
          expect(SubmissionManagementChargeCalculationJob).not_to have_been_enqueued.with(submission)
        end
      end

      context 'with all entries validated' do
        let(:submission) { FactoryBot.create(:submission_with_validated_entries, aasm_state: :processing) }
        before { submission_status_check.perform! }

        it 'leaves the submission in a "processing" state' do
          expect(submission).to be_processing
        end

        it 'queues a management charge calculation' do
          expect(SubmissionManagementChargeCalculationJob).to have_been_enqueued.with(submission)
        end
      end

      context 'with some "pending" entries and some "errored" entries' do
        let(:submission) do
          FactoryBot.create(:submission_with_pending_entries, aasm_state: :processing).tap do |submission|
            create(:invoice_entry, :errored, submission: submission)
          end
        end
        before { submission_status_check.perform! }

        it 'leaves the submission in a "processing"' do
          expect(submission).to be_processing
        end

        it 'does not queue a management charge calculation' do
          expect(SubmissionManagementChargeCalculationJob).not_to have_been_enqueued.with(submission)
        end
      end

      context 'with no "pending" entries remaining, but some having failed validation' do
        let(:submission) { FactoryBot.create(:submission_with_invalid_entries, aasm_state: :processing) }
        before { submission_status_check.perform! }

        it 'transitions the submission to "validation_failed"' do
          expect(submission).to be_validation_failed
        end

        it 'does not queue a management charge calculation' do
          expect(SubmissionManagementChargeCalculationJob).not_to have_been_enqueued.with(submission)
        end
      end

      context 'with ingest still in progress (i.e. entries count doesn’t match files#rows)' do
        let(:submission) do
          FactoryBot.create(
            :submission_with_validated_entries,
            files: [FactoryBot.build(:submission_file)],
            aasm_state: :processing
          ).tap do |submission|
            entries_count = submission.entries.count
            submission.files.last.update!(rows: (entries_count + 1))
          end
        end
        before { submission_status_check.perform! }

        it 'leaves the submission in a "processing"' do
          expect(submission).to be_processing
        end

        it 'does not queue a management charge calculation' do
          expect(SubmissionManagementChargeCalculationJob).not_to have_been_enqueued.with(submission)
        end
      end
    end
  end
end
