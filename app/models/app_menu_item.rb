class AppMenuItem < ApplicationRecord
  belongs_to :organization
  acts_as_list scope: :organization
end