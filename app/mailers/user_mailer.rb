# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer
	include "json"
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
		if not Report.exists? report_id and Integer(report.creator.organization_id) == 3
      return
    end
		report = Report.find(report_id)
		@user = user
		@message = message
		@url = report.pdf_url
		@sub = report.dynamic_attributes.dig("subtitle")
		@area, @category = @sub.split("/")
		file = File.read('./email_manflas.json')
		@message = "manflas"
		@data = JSON.parse(file)
		@cc = @data[:@area][:@category]
		mail(to: cc, subject: "manflas", from:"Admin<solutions@ewin.cl>")

		#@mails = "smorales@bildchile.com,lguanco@bildchile.com,#{@user.email}"
		#mail(to: 'smorales@bildchile.com, nvera@bildchile.com, pruebas.bild@gmail.com', subject: "Manflas - Se generado un reporte",
						from: "Admin<solutions@ewin.cl>")
		#mail(to: @mails, subject: "Manflas - Se generado un reporte",
		#				  from: "Admin<solutions@ewin.cl>")
		#if Integer(report.creator.organization_id) == 3
		#	if report.dynamic_attributes.dig("subtitle") != nil
		#		user = report.dynamic_attributes.dig("assigned_user")
		#		if user != nil and user != ""
		#			 #Rails.logger.debug "Mails: smorales@bildchile.com, #{user.email}, #{@json[:area][:category]}"
		#			 mail(to: 'smorales@bildchile.com,lguanco@bildchile.com,', #+ user.email,
		#				 subject: "Manflas - Se generado un reporte", cc: @json[:area][:category],
		#				  from: "Admin<solutions@ewin.cl>")
		#		end
		#	end
		#end
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
