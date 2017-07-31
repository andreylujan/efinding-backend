class ConstructionUser < ApplicationRecord
  belongs_to :construction
  belongs_to :user
end
