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


class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :full_name,
    :rut, :address, :image, :role_name, :role_id, :phone_number,
    :organization_name, :is_checked_in, :organization_id

    def is_checked_in
    	checkin = object.checkins.last
    	if checkin.nil?
    		return false
    	end

    	if checkin.exit_time.present?
    		return false
    	end

    	true
    end

    def role_name
    	object.role.name
    end

    def organization_name
    	object.role.organization.name
    end
end
