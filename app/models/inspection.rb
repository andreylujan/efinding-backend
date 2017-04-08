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
#  final_signer_id   :integer
#  initial_signed_at :datetime
#  final_signed_at   :datetime
#  field_chief_id    :integer
#  expert_id         :integer
#  cached_data       :json
#  code              :integer
#

class Inspection < ApplicationRecord

  acts_as_paranoid

  belongs_to :construction
  has_one :company, through: :construction

  has_many :reports, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  belongs_to :initial_signer, class_name: :User, foreign_key: :initial_signer_id
  belongs_to :final_signer, class_name: :User, foreign_key: :final_signer_id

  belongs_to :field_chief, class_name: :User, foreign_key: :field_chief_id
  belongs_to :expert, class_name: :User, foreign_key: :expert_id

  validates :construction, presence: true
  validates :creator, presence: true
  validates :state, presence: true
  before_create :cache_data

  mount_uploader :pdf, PdfUploader

  before_validation(on: :create) do
    self.code = next_seq unless attribute_present? :code
  end

  def company_id
    construction.company_id
  end

  def field_chief_name
    personnel = construction.construction_personnel.where(personnel_type_id: 1)
    if personnel.count > 0
      personnel.first.personnel.name
    else
      "Sin Jefe de erreno"
    end
  end

  def expert_name
    if construction.expert.present?
      construction.expert.name
    else
      "Sin Experto SSOMA"
    end
  end

  def cache_data
    if not cached_data
      self.cached_data = {}
    end
    construction.construction_personnel.each do |personnel|
      type_id = personnel.personnel_type_id
      self.cached_data[type_id.to_s] = personnel.personnel.name
    end
    if construction.expert.present?
      self.cached_data["expert"] = construction.expert.name
    end
  end

  def generate_pdf
    if not self.pdf_uploaded?
      regenerate_pdf
    end
  end

  def formatted_created_at
    created_at.strftime("%d/%m/%Y")
  end

  def formatted_resolved_at
    if state == "final_signature_pending" || state == "finished"
      report = reports.order("resolved_at DESC").first
      if report.present?
        report.resolved_at.strftime("%d/%m/%Y")
      end
    end
  end

  def formatted_final_signed_at
    final_signed_at.strftime("%d/%m/%Y") if final_signed_at.present?
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
      self.resolved_at = DateTime.now
      resolve_reports!
    end
  end



  def state_name
    if state == "final_signature_pending" || state == "finished"
      "Resuelto"
    else
      "Pendiente"
    end
  end

  state_machine :state, initial: :reports_pending do

    after_transition any => :first_signature_done do |inspection, transition|
      inspection.initial_signed_at = DateTime.now
    end

    after_transition any => :first_signature_pending do |inspection, transition|
      users = [ inspection.construction.administrator ]
      users.each do |user|
        UserMailer.delay(queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
          .inspection_email(user, 'Solicitud de firma de inspección',
            "#{inspection.construction.supervisor.name} ha enviado una nueva inspección para ser firmada " +
            "en la obra #{inspection.construction.name}.")
      end
    end

    after_transition any => :final_signature_pending do |inspection, transition|
      users = [ inspection.construction.administrator, inspection.construction.supervisor ]
      users.each do |user|
        UserMailer.delay(queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
          .inspection_email(user)
      end
    end

    after_transition any => :finished do |inspection, transition|
      inspection.final_signed_at = DateTime.now
      UserMailer.delay(queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
        .inspection_email(inspection.construction.supervisor)
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

  private
  def next_seq
    last = self.construction.inspections.with_deleted.order("code DESC").first
    if last.nil?
      1
    else
      last.code + 1
    end
  end
end
