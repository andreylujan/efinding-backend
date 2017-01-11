# -*- encoding : utf-8 -*-
class Api::V1::InvitationsController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!, only: :create
  before_action :authorize_confirmation_token!, only: :update

  private
  def authorize_confirmation_token!
    token = params.require(:confirmation_token)
    invitation = Invitation.find_by_confirmation_token!(token)
  end


end
