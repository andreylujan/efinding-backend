# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: checklist_reports
#
#  id              :uuid             not null, primary key
#  report_type_id  :integer          not null
#  construction_id :integer          not null
#  creator_id      :integer          not null
#  location_id     :integer          not null
#  pdf             :text
#  pdf_uploaded    :boolean          default(FALSE), not null
#  deleted_at      :datetime
#  html            :text
#  location_image  :text
#  checklist_data  :json             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  code            :integer          not null
#  checklist_id    :integer
#  started_at      :datetime
#

class ChecklistReport < ApplicationRecord
  belongs_to :report_type
  belongs_to :construction
  belongs_to :location
  belongs_to :checklist
  belongs_to :creator, class_name: :User, foreign_key: :creator_id
  has_and_belongs_to_many :users

  validates :report_type, presence: true
  validates :construction, presence: true
  validates :location, presence: true
  validates :creator, presence: true
  validates :code, presence: true
  validates :id, uniqueness: true

  mount_uploader :pdf, PdfUploader
  mount_uploader :html, HtmlUploader
  mount_uploader :location_image, ImageUploader

  accepts_nested_attributes_for :location
  acts_as_paranoid

  after_commit :generate_pdf
  after_commit :send_email, on: [ :create ]

  attr_accessor :ignore_pdf

  before_validation(on: :create) do
    self.code = next_seq unless attribute_present? :code
  end

  def user_names
    names = []
    if construction.users.experts.count > 0
      experts = construction.users.experts.map { |u| u.name }
      names = names + experts
    end
    if construction.administrator.present?
      names << construction.administrator.name
    end
    names.uniq.sort.join(', ')
  end

  def generate_pdf
    if not @ignore_pdf and not self.pdf_uploaded?
      regenerate_pdf
    end
  end

  def send_email
    # UserMailer.delay_for(5.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
    #  .report_email(self.id, self.assigned_user,
    #                "Tarea asignada",
    #                "#{creator.name} ha generado una tarea para tu área.")
    user_ids = []
    user_ids << creator_id
    user_ids = user_ids | construction.user_ids
    user_ids = user_ids | [ construction.supervisor_id, construction.administrator_id ]
    user_ids = user_ids.select { |i| i.present? }.uniq
    user_ids.each do |user_id|
      UserMailer.delay_for(5.seconds, queue: ENV['EMAIL_QUEUE'] || 'echeckit_email')
        .checklist_email(self.id, user_id,
          "Checklist creado",
          "#{creator.name} ha generado un checklist de tipo: #{checklist.name}."
          )
    end
  end

  def total_indicator
    num_check = 0
    num_cross = 0
    if checklist_data.is_a? Array
      checklist_data.each do |section|
        section["items"].each do |item|
          if item["value"].present? and item["value"] == 1
            num_check = num_check + 1
          elsif item["value"].present? and item["value"] == 2
            num_cross = num_cross + 1
          end
        end
      end
      num_total = num_check + num_cross
      if num_total == 0
        "100%"
      else
        (num_check.to_f * 100.0 / num_total.to_f).round.to_s + "%"
      end
    else
      "100%"
    end
  end

  def has_value_for_section(section)
    section["items"].inject(0) do |sum, x|
      if x["value"].present? and x["value"] != 0
        sum + 1
      elsif x["items"].present? and x["items"].length > 0
        sum + x["items"].inject(0) { |subsum, y| if y["value"].present? and y["value"] != 0 then subsum + 1 else subsum end }
      else
        sum
      end
    end > 0
  end

  def regenerate_pdf(force_random = false)
    if force_random
      update_columns pdf: nil, pdf_uploaded: false
    end
    ChecklistPdfJob.set(queue: ENV['REPORT_QUEUE'] || 'echeckit_report').perform_later(self.id.to_s)
  end

  def formatted_created_at
    created_at.strftime("%d/%m/%Y %R")
  end

  private
  def next_seq
  	last = self.construction.checklist_reports.with_deleted.order("code DESC").first
    if last.nil?
      1
    else
      last.code + 1
    end
  end


end
