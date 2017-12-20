# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer

	default from: 'eFinding Admin<solutions@ewin.cl>'

	def invite_email(invitation)
		@invitation = invitation
		@url = "#{ENV['ADMIN_URL']}/#/signup"
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

	def checklist_email(checklist_id, user, subject, message)
		report = ChecklistReport.find(checklist_id)
		@user = user
		@message = message
		@url = report.pdf_url
		mail(to: @user.email, subject: subject)
	end
	def manflas_email(report_id)
		if not Report.exists? report_id
      return
    end
		report = Report.find(report_id)
		@file = File.read('./email_manflas.json')
		@json = JSON.parse(@file)
		s = "subtitle"
		u = "assigned_user"
		if Integer(report.creator.organization_id) == 3
			if report.dynamic_attributes.dig(@s, "text") != nil
				user = report.dynamic_attributes.dig(@u, "user")
				if user != nil and user != ""
					 a = report.dynamic_attributes.dig(@s, "text")
					 a.downcase
					 area, category = a.split('/')
					 Rails.logger.debug "Mails: smorales@bildchile.com #{@user[:email]} #{@json[:@area][:@category]}"
					 mail(to: 'smorales@bildchile.com,lguanco@bildchile.com,' + @user[:email],
						 subject: "Manflas - Se generado un reporte", cc: @json[:@area][:@category],
						  from: "Admin<solutions@ewin.cl>")
				end
			end
		end
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
