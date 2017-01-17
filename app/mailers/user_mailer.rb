# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer

	default from: 'e-Checkit Admin<solutions@ewin.cl>'

	def invite_email(invitation)
		@invitation = invitation
		@url = Rails.env.production? ? "http://50.16.161.152/generic/admin/#/signup" : "http://50.16.161.152/generic-staging/admin/#/signup"
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
	
	def report_email()
	end

end
