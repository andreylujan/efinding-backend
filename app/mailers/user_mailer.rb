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

	def report_email(report_id, user, subject, message)
		report = Report.find(report_id)
		@user = user
		@message = message
		@url = report.pdf_url
		mail(to: @user.email, subject: subject)
	end
	
	def inspection_email(inspection_id, user, subject, message)
		inspection = Inspection.find(inspection_id)
		@user = user
		@message = message
		@url = inspection.pdf_url
		mail(to: @user.email, subject: subject)
	end
end
