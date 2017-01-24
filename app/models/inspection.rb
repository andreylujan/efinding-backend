# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: inspections
#
#  id              :integer          not null, primary key
#  construction_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  resolved_at     :datetime
#  signer_id       :integer
#  signed_at       :datetime
#

class Inspection < ApplicationRecord

  acts_as_paranoid

  belongs_to :construction
  has_many :reports, dependent: :destroy
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :initial_signer, class_name: :User, foreign_key: :signer_id
  validates :construction, presence: true
  validates :creator, presence: true
  validates :state, presence: true
  has_and_belongs_to_many :users

  def num_reports
    reports.count
  end

  state_machine :state, initial: :reports_pending do

    event :send_for_revision do
      transition :reports_pending => :first_signature_pending
    end

    event :sign do
      transition :first_signature_pending => :first_signature_done
    end

    event :resolve_reports do
      transition :first_signature_done => :final_signature_pending
    end

    event :finalize do
    	transition :final_signature_pending => :finished
    end

  end
end
