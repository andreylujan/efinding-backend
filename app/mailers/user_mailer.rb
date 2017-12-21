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

	def manflas_email(report_id, user)
		report = Report.find(report_id)
		if Integer(report.creator.organization_id) == 3
			if report.dynamic_attributes["subtitle"]!= nil
				a = report.dynamic_attributes["subtitle"]
				a.downcase
				area, category = s.split('/')
				file = File.read('./email_manflas.json')
				mailJson = JSON.parse(file)
				@user = user
				@message = "Se ha generado un nuevo reporte"
				@url = report.pdf_url
				cc = mailJson.fetch(area).fetch(category)
				mail(to:@user.email, subject:"Manflas - se ha generado unb nuevo reporte", cc:cc, from: "Admin<solutions@ewin.cl>")
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
