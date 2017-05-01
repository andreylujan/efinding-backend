# -*- encoding : utf-8 -*-
class Api::V1::InvitationsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!, only: :create
  before_action :authorize_confirmation_token!, only: :update

  def create
    role_id = params.dig(:data, :relationships, :role, :data, :id)
    if role_id.nil?
      role_id = params.dig(:data, :attributes, :role_id)
    end
    if role_id.present?
      role = Role.find(role_id)
      if current_user.organization_id != role.organization_id
        render json: unauthorized_error, status: :unauthorized
        return
      end
    end
    super
  end

  private
  def authorize_confirmation_token!
    token = params.require(:confirmation_token)
    invitation = Invitation.find_by_confirmation_token!(token)
  end
end
