require 'rails_helper'

RSpec.describe Task do
  it { is_expected.to validate_presence_of(:status) }

  it { is_expected.to belong_to(:framework) }
  it { is_expected.to belong_to(:supplier) }

  it { is_expected.to have_many(:submissions) }

  it "defaults to an 'unstarted' state" do
    expect(Task.new.status).to eq 'unstarted'
  end

  describe '#latest_submission' do
    let(:task) { FactoryBot.create(:task) }

    it 'returns the most recent submission' do
      _old_submission = FactoryBot.create(:submission, task: task)

      travel 1.day do
        latest_submission = FactoryBot.create(:submission, task: task)

        expect(task.latest_submission).to eq latest_submission
      end
    end
  end

  describe '#file_no_business!' do
    let(:task) { FactoryBot.create(:task) }
    let(:user) { FactoryBot.create(:user) }

    it 'creates an empty completed submission' do
      expect { task.file_no_business!(user) }.to change { task.submissions.count }.by 1

      submission = task.latest_submission

      expect(submission).to be_completed
      expect(submission.entries).to be_empty
    end

    it 'transitions the task to "completed"' do
      task.file_no_business!(user)
      expect(task.reload).to be_completed
    end

    it 'records the user who created the submission' do
      task.file_no_business!(user)
      submission = task.latest_submission

      expect(submission.created_by).to eq(user)
    end

    it 'records the user who completed the submission' do
      task.file_no_business!(user)
      submission = task.latest_submission

      expect(submission.submitted_by).to eq(user)
    end

    it 'records the submission time' do
      submission_time = Time.zone.local(2018, 1, 10, 12, 13, 14)

      travel_to(submission_time) do
        task.file_no_business!(user)
        submission = task.latest_submission

        expect(submission.submitted_at).to eq(submission_time)
      end
    end
  end

  describe '#period_date' do
    it 'returns a date for the task’s period' do
      task = Task.new(period_year: 2020, period_month: 5)
      expect(task.period_date).to eq Date.new(2020, 5, 1)
    end
  end
end
