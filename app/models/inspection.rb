# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: inspections
#
#  id                :integer          not null, primary key
#  construction_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  creator_id        :integer
#  resolved_at       :datetime
#  initial_signer_id :integer
#  signed_at         :datetime
#  state             :text
#  deleted_at        :datetime
#  pdf               :text
#  pdf_uploaded      :boolean          default(FALSE), not null
#

class Inspection < ApplicationRecord

  acts_as_paranoid

  belongs_to :construction
  has_many :reports, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :initial_signer, class_name: :User, foreign_key: :initial_signer_id
  belongs_to :final_signer, class_name: :User, foreign_key: :final_signer_id
  validates :construction, presence: true
  validates :creator, presence: true
  validates :state, presence: true
  has_and_belongs_to_many :users
  mount_uploader :pdf, PdfUploader

  def generate_pdf
    if not self.pdf_uploaded?
      regenerate_pdf
    end
  end

  def num_pending_reports
    reports.where(state: "unchecked").count
  end

  def formatted_created_at
    created_at.strftime("%d/%m/%Y %R") 
  end

  def formatted_resolved_at
    if state == "final_signature_pending" || state == "finished"
      report = reports.order("resolved_at DESC").first
      if report.present?
        report.resolved_at.strftime("%d/%m/%Y %R") 
      end
    end
  end

  def formatted_final_signed_at
    final_signed_at.strftime("%d/%m/%Y %R") if final_signed_at.present?
  end

  def regenerate_all_pdfs
    regenerate_pdf(true)
    reports.each do |report|
      report.regenerate_pdf(true)
    end
  end

  def regenerate_pdf(force_random = false)
    if force_random
      update_columns pdf: nil, pdf_uploaded: false
    end
    InspectionPdfJob.set(queue: ENV['REPORT_QUEUE'] || 'echeckit_report').perform_later(self.id.to_s)
  end

  def check_state
    if state == "first_signature_done" and reports.where(state: "unchecked").count == 0
      resolve_reports!
    end
  end

  def num_reports
    reports.count
  end

  state_machine :state, initial: :reports_pending do

    after_transition any => :first_signature_done do |inspection, transition|
      inspection.initial_signed_at = DateTime.now
    end

    after_transition any => :finished do |inspection, transition|
      inspection.final_signed_at = DateTime.now
    end
  

    event :send_for_revision do
      transition :reports_pending => :first_signature_pending
    end

    event :sign do
      transition first_signature_pending: :first_signature_done, final_signature_pending: :finished
    end

    event :resolve_reports do
      transition :first_signature_done => :final_signature_pending
    end


  end
end
