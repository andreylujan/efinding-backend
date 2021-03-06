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

  acts_as_xlsx columns: [
    :id,
    :created_at,
    :creator_name,
    :resolved_at,
    :initial_signer_name,
    :initial_signed_at,
    :state,
    :pdf_url,
    :final_signer_name,
    :final_signed_at,
    :construction_name,
    :company_name

    # :created_at,
    # :finished_at,
    # :limit_date,
    # :creator_email,
    # :assigned_user_email,
    # :start_location_coords,
    # :finish_location_coords,
    # :location_delta,
    # :execution_time,
    # :pdf_url
  ]

  def self.column_translations
    {
      id: "Id inspección",
      construction_name: "Nombre obra",
      company_name: "Nombre empresa",
      created_at: "Fecha de creación",
      creator_name: "Nombre creador",
      resolved_at: "Fecha de resolución",
      initial_signer_name: "Primer firmante",
      initial_signed_at: "Fecha primera firma",
      state: "Estado",
      pdf_url: "PDF",
      final_signer_name: "Último firmante",
      final_signed_at: "Fecha última firma"
    }
  end

  def self.setup_xlsx
    cols = []
    column_translations.each do |key, value|
      define_method :"#{value}" do
        send key
      end
      cols << "#{value}"
    end
    Inspection.acts_as_xlsx columns: cols
  end

  def creator_name
    creator.name
  end

  def initial_signer_name
    if initial_signer.present?
      initial_signer.name
    end
  end

  def final_signer_name
    if final_signer.present?
      final_signer.name
    end
  end

  def construction_name
    construction.name
  end

  def company_name
    construction.company.name
  end

  before_validation(on: :create) do
    self.code = next_seq unless attribute_present? :code
  end

  def company_id
    construction.company_id
  end

  def personnel_by_name(name)
    personnel = construction.construction_personnel
    .joins(:personnel_type)
    .where(personnel_types: { name: name })
    if personnel.count > 0
      personnel.first.personnel.name
    else
      "Sin #{name}"
    end
  end

  def field_chief_name
    personnel_by_name("Jefe de Terreno")
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
        UserMailer.delay_for(8.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
        .inspection_email(inspection.id, user, "Solicitud de firma - #{inspection.construction.name}",
                          "#{inspection.construction.supervisor.name} ha enviado una nueva inspección para ser firmada " +
                          "en la obra #{inspection.construction.name}. " +
                          "Para realizar la firma, puedes ingresar a http://50.16.161.152/efinding/admin/#/efinding/inspecciones/lista")
      end
    end

    after_transition any => :final_signature_pending do |inspection, transition|
      UserMailer.delay_for(8.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
      .inspection_email(inspection.id, inspection.construction.administrator,
                        "Solicitud de firma final - #{inspection.construction.name}",
                        "#{inspection.construction.expert.name} ha cerrado los hallazgos para la inspección #{inspection.id} - #{inspection.construction.name}. " +
                        "Para realizar la firma final, puedes ingresar a http://50.16.161.152/efinding/admin/#/efinding/inspecciones/lista")

      UserMailer.delay_for(8.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
      .inspection_email(inspection.id, inspection.construction.supervisor,
                        "Aviso de levantamiento - #{inspection.construction.name}",
                        "Se informa que #{inspection.construction.expert.name} ha cerrado los hallazgos para la inspección #{inspection.id} - #{inspection.construction.name}. " +
                        "Se ha enviado una solicitud de firma al Administrador de Obra #{inspection.construction.administrator.name}.")
    end

    after_transition any => :finished do |inspection, transition|
      inspection.final_signed_at = DateTime.now
      UserMailer.delay_for(8.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
      .inspection_email(inspection.id, inspection.construction.supervisor,
                        "Firma final realizada - #{inspection.construction.name}",
                        "#{inspection.construction.administrator.name} ha realizado la firma final para la inspección #{inspection.id} - #{inspection.construction.name}.")
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
