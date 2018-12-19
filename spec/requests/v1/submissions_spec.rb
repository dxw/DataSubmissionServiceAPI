require 'rails_helper'

RSpec.describe '/v1' do
  let(:user) { FactoryBot.create(:user) }
  describe 'GET /submissions/:submission_id' do
    it 'returns the requested submission' do
      submission = FactoryBot.create(:submission)

      get "/v1/submissions/#{submission.id}", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)
    end

    it 'optionally includes submission files' do
      submission = FactoryBot.create(:submission)
      file = FactoryBot.create(:submission_file, submission: submission)

      get "/v1/submissions/#{submission.id}?include=files", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to be_successful
      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:files)
        .with_data([{ 'id' => file.id, 'type' => 'submission_files' }])
    end

    it 'optionally includes submission framework' do
      framework = FactoryBot.create(:framework, short_name: 'RM1234')
      submission = FactoryBot.create(:submission, framework: framework)

      get "/v1/submissions/#{submission.id}?include=framework", headers: { 'X-Auth-Id' => user.auth_id }
      expect(response).to be_successful

      expect(json['data']).to have_id(submission.id)
      expect(json['data'])
        .to have_relationship(:framework)
        .with_data('id' => framework.id, 'type' => 'frameworks')
      expect(json['included'][0].dig('attributes', 'short_name')).to eql 'RM1234'
    end
  end

  describe 'POST /submissions' do
    it 'creates a new submission and returns its id' do
      framework = FactoryBot.create(:framework)
      supplier  = FactoryBot.create(:supplier)
      task = FactoryBot.create(:task, framework: framework, supplier: supplier)

      params = {
        data: {
          type: 'submissions',
          attributes: {
            task_id: task.id,
            purchase_order_number: 'INV-123'
          }
        }
      }

      post "/v1/submissions?task_id=#{task.id}",
           params: params.to_json,
           headers: json_headers.merge('X-Auth-Id' => user.auth_id)

      expect(response).to have_http_status(:created)

      submission = Submission.first

      expect(json['data']).to have_id(submission.id)
      expect(json['data']).to have_attribute(:framework_id).with_value(framework.id)
      expect(json['data']).to have_attribute(:supplier_id).with_value(supplier.id)
      expect(json['data']).to have_attribute(:task_id).with_value(task.id)
      expect(json['data']).to have_attribute(:purchase_order_number).with_value('INV-123')
    end
  end

  describe 'POST /submissions/:submission_id/complete' do
    context 'given a valid submission' do
      it 'marks the submission as complete' do
        task = FactoryBot.create(:task, status: :in_progress)

        submission = FactoryBot.create(
          :submission_with_validated_entries,
          aasm_state: :in_review,
          task: task
        )

        post "/v1/submissions/#{submission.id}/complete", headers: { 'X-Auth-Id' => user.auth_id }

        expect(response).to be_successful

        submission.reload

        expect(submission).to be_completed
        expect(submission.task).to be_completed
      end
    end

    context 'given an invalid submission' do
      it 'returns an error' do
        task = FactoryBot.create(:task, status: :in_progress)

        submission = FactoryBot.create(
          :submission_with_invalid_entries,
          aasm_state: :in_review,
          task: task
        )

        post "/v1/submissions/#{submission.id}/complete", headers: { 'X-Auth-Id' => user.auth_id }

        expect(response).to have_http_status(:bad_request)
        expect(json['errors'][0]['title']).to eql 'Invalid aasm_state'

        submission.reload

        expect(submission).to be_in_review
        expect(task).to be_in_progress
      end
    end
  end

  describe 'POST /submissions/:submission_id/validate' do
    it 'triggers the validation of the requested submission' do
      submission = FactoryBot.create(:submission_with_pending_entries)

      post "/v1/submissions/#{submission.id}/validate", headers: { 'X-Auth-Id' => user.auth_id }

      expect(response).to have_http_status(:no_content)
      expect(SubmissionValidationJob).to have_been_enqueued.with(submission)
    end
  end
end
