# -*- encoding : utf-8 -*-

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
