# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer

	default from: 'eFinding Admin<solutions@ewin.cl>'

	def invite_email(invitation)
		@invitation = invitation
		if @invitation.organization.echeckit?
			url_suffix = Rails.env.production? ? "echeckit" : "echeckit-staging"
		else
			url_suffix = Rails.env.production? ? "efinding" : "efinding-staging"
		end
		@url = "#{ENV['BASE_ADMIN_URL']}/#{url_suffix}/admin/#/signup"
		mail(to: @invitation.email, subject: "Únete a #{invitation.role.organization.name}",
			from: "#{invitation.role.organization.name} Admin<solutions@ewin.cl>",
			template_name: "invite_#{invitation.role.organization.app_name}")
	end	

	def confirmation_email(user)
		@user = user
		mail(to: @user.email, subject: "Bienvenido a #{user.organization.name}",
			from: "#{user.organization.name} Admin<solutions@ewin.cl>")
	end

	def reset_password_email(user)
		@user = user
		mail(to: @user.email, subject: 'Recuperación de contraseña')
	end
	
	def inspection_email(inspection_id, user, subject, message)
		inspection = Inspection.find(inspection_id)
		@user = user
		@message = message
		@url = inspection.pdf_url
		mail(to: @user.email, subject: subject)
	end

	def report_email()
	end

end
