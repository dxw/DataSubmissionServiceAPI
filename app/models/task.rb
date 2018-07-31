class Task < ApplicationRecord
  include AASM

  aasm column: 'status' do
    state :draft
    state :unstarted, initial: true
    state :in_progress
    state :completed
    state :cancelled

    event :completed do
      transitions from: %i[unstarted in_progress], to: :completed
    end
  end

  validates :status, presence: true

  belongs_to :framework, optional: true
  belongs_to :supplier

  has_many :submissions, dependent: :nullify
  has_one :latest_submission, -> { order(created_at: :desc) }, inverse_of: :task, class_name: 'Submission'

  def self.for_user_id(user_id)
    supplier_ids = Membership
                   .where(user_id: user_id)
                   .pluck(:supplier_id)

    where(supplier_id: supplier_ids)
  end

  def file_no_business!
    transaction do
      completed!
      submissions.create!(framework: framework, supplier: supplier, aasm_state: :completed)
    end
  end
end
