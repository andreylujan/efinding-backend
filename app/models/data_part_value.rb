class DataPartValue < ApplicationRecord
  belongs_to :report
  belongs_to :collection_item
  belongs_to :data_part

  validates :report, presence: true
  validates :data_part, presence: true, uniqueness: { scope: :report }
end
