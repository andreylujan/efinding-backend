# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: invitations
#
#  id                 :integer          not null, primary key
#  role_id            :integer          not null
#  confirmation_token :text             not null
#  email              :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  accepted           :boolean          default(FALSE), not null
#  first_name         :text
#  last_name          :text
#  internal_id        :text
#

class Invitation < ApplicationRecord

  belongs_to :role

  validates_presence_of [ :email ]
  validates_uniqueness_of :email
  validates_uniqueness_of :internal_id, allow_nil: true
  before_create :generate_confirmation_token
  delegate :organization, to: :role, allow_nil: false

  before_validation :lowercase_email
  before_validation :verify_email, on: :create
  validate :user_existence
  after_create :send_email
  validates :email, format: /(.)+@(\w)+/

  def send_email
    UserSendGridMailer.invite_email(self).deliver
  end

  private


  def user_existence
    user = User.find_by_email(self.email)
    if user.present?
      errors.add(:email, "Ya existe un usuario con este correo")
    end
  end

  def lowercase_email
    self.email = self.email.downcase if self.email.present?
  end

  def verify_email
    if self.email.present?
      old_invitation = Invitation.find_by_email(self.email)
      if old_invitation
        old_invitation.destroy
      end
    end
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(64)
  end

end
