# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer

	default from: 'eFinding Admin<solutions@ewin.cl>'

	def invite_email(invitation)
		@invitation = invitation
		@url = Rails.env.production? ? "http://50.16.161.152/efinding/admin/#/signup" : "http://50.16.161.152/efinding-staging/admin/#/signup"
		mail(to: @invitation.email, subject: "Únete a #{invitation.role.organization.name}",
			from: "#{invitation.role.organization.name} Admin<solutions@ewin.cl>")
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
	
	def inspection_email(user, subject, message)
		@user = user
		@message = message
		@url = "http://50.16.161.152/efinding/admin/#/efinding/inspecciones/lista"
		mail(to: @user.email, subject: subject)
	end

	def report_email()
	end

end
