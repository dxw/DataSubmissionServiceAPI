class FrameworkLot < ApplicationRecord
  belongs_to :framework

  validates :number, presence: true, uniqueness: true
end
