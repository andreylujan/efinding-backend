# -*- encoding : utf-8 -*-
class Api::V1::UsersController < Api::V1::JsonApiController

  before_action :doorkeeper_authorize!, except: [
    :reset_password_token,
    :verify,
    :create,
  :password ]

  before_action :verify_invitation, only: :create

  def reset_password_token
    email = params.require(:email)
    user = User.find_by_email(email)
    if user
      user.send_reset_password_instructions
    end
    render json: {
      data: {
        id: (DateTime.now.to_f*1000).to_i,
        type: "reset_password_tokens",
        attributes: {
          success: true
        }
      }
    }
  end

  def index
    org_id = current_user.role.organization_id
    if params[:organization_id].present?
      if org_id.to_s != params[:organization_id].to_s
        render json: unauthorized_error, status: :unauthorized
        return
      end
    end
    org_users = User.includes(:role).
      where(roles: { organization_id: org_id }, deleted_at: nil)

    # Temporary fix for inconsistency
    if params[:organization_id].blank?
      user_emails = org_users.map { |u| u.email }
      invitations = Invitation.includes(:role)
      .where(roles: { organization_id: org_id })
      .where.not(email: user_emails)
      inv_users = []
      invitations.each do |i|
        inv_users << User.new(email: i.email, role: i.role)
      end
      all_users = org_users.to_a.concat(inv_users)
    else
      all_users = org_users.to_a
    end

    json = {}
    data = []
    all_users.each do |user|
      attributes = UserIndexSerializer.new(user).as_json
      attributes[:active] = user.persisted?
      user_data = {
        "id": user.id ? user.id.to_s : "",
        "type": "users",
        "attributes": attributes
      }
      data << user_data
    end
    json[:data] = data
    render json: json
  end


  def verify
    token = params.require(:reset_password_token)
    email = params.require(:email)
    @user = User.find_by_reset_password_token_and_email(token, email)
    if @user
      render json: JSONAPI::ResourceSerializer.new(Api::V1::UserResource)
      .serialize_to_hash(Api::V1::UserResource.new(@user, nil))
    else
      render json: unauthorized_error, status: :unauthorized
    end
  end

  def all
    users = User.joins(:role).where(roles: {
                                      organization_id: current_user.role.organization_id
    })
    render json: users, each_serializer: UserIndexSerializer
  end

  def password
    @user = User.find(params.require(:id))

    if params[:reset_password_token].blank? and params[:old_password].blank?
      render json: unauthorized_error, status: :unauthorized and return
    end

    if params[:old_password].present? and not @user.valid_password? params[:old_password]
      render json: unauthorized_error, status: :unauthorized and return
    end

    if params[:reset_password_token].present? and @user.reset_password_token != params.require(:reset_password_token)
      render json: unauthorized_error, status: :unauthorized and return
    end

    if @user.update_attributes(
        password: params.require(:password),
        password_confirmation: params.require(:password_confirmation)
      )
      token = Doorkeeper::AccessToken.find_or_create_for(nil, @user.id, 'user', 7200, true)
      body = response_from_token(token)
      render json: body
    else
      render json: {
        errors: @user.errors.full_message
      }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params.require(:id))
    if user.organization == current_user.organization
      if user.deleted_at.nil?
        user.update_attributes deleted_at: DateTime.now, password: SecureRandom.uuid
        Doorkeeper::AccessToken.where(resource_owner_id: user.id).destroy_all
        render nothing: true, status: :no_content
      else
        render json: {
          errors: [ { title: "Usuario ya fue borrado", detail: "Este usuario ya fue eliminado anteriormente "}]
        }, status: :unprocessable_entity
      end
    else
      render json: {
        errors: [ { title: "No permitido", detail: "No puede eliminar usuarios de otra organización" }]
      }, status: :unprocessable_entity
    end
  end

  private
  def user_params
  end

  def verify_invitation
    token = params.require(:confirmation_token)
    inv = Invitation.find_by_confirmation_token_and_accepted(token, true)
    if inv.nil? or not inv.accepted?
      render json: {
        errors: [
          {
            title: 'Invitación no fue aceptada',
            detail: 'La invitación no fue aceptada a través del link del correo'
          }
        ]
      }, status: :unauthorized
    end
  end

end
