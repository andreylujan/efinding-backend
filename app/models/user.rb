# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rut                    :text
#  first_name             :text
#  last_name              :text
#  phone_number           :text
#  address                :text
#  image                  :text
#  role_id                :integer          not null
#  deleted_at             :datetime
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :validatable

  validates :email, uniqueness: true, presence: true
  validates :rut, uniqueness: true, allow_nil: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, uniqueness: true, allow_nil: true
  belongs_to :role
  before_create :assign_role_id
  has_many :access_tokens, foreign_key: :resource_owner_id, class_name: 'Doorkeeper::AccessToken'
  has_many :devices, dependent: :destroy
  delegate :organization, to: :role, allow_nil: false
  delegate :organization_id, to: :role, allow_nil: false
  has_many :created_reports, class_name: :Report, foreign_key: :creator_id
  has_many :assigned_reports, class_name: :Report, foreign_key: :assigned_user_id
  after_create :send_confirmation_email
  has_many :checkins
  has_many :batch_uploads

  def send_confirmation_email
    UserMailer.delay(queue: ENV['EMAIL_QUEUE'] || 'echeckit_email').confirmation_email(self)
  end

  def send_reset_password_instructions
    token = set_reset_password_token
    UserMailer.delay(queue: ENV['EMAIL_QUEUE'] || 'echeckit_email').reset_password_email(self)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def name
    full_name
  end

  def viewable_reports
    Report.where("assigned_user_id = ? or creator_id = ?", self.id, self.id)
  end

  def assign_role_id
    inv = Invitation.find_by_email(self.email)
    if inv.present?
      self.role_id = inv.role_id
    end

    if self.role_id.nil?
      self.role = Role.first
    end
  end

  def set_reset_password_token
    token = ""
    4.times do |i|
      token = token + rand(10).to_s
    end
    self.reset_password_token = token
    self.reset_password_sent_at = Time.now.utc
    self.save validate: false
    token
  end
end
