# -*- encoding : utf-8 -*-
class UserMailer < ApplicationMailer
	require 'json'

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

	def pausa_email(report)
		@reporte =  report

		case Integer(report.organization_id)
		when 11
			@d = "116"
			@solicitud = report.dynamic_attributes.dig(@d, "value")
			@mantencion = report.dynamic_attributes.dig("115", "value")
			if  @solicitud != ""
				mail(to: 'pruebas.bild@gmail.com, jguerrero80@gmail.com,leslienilu@hotmail.com,lesliepassalacqua@pausaperu.pe, lguanco@bildchile.com, Luisaleon@pausaperu.pe', subject: "PAUSA PERÚ - Se generado una Solicitud de Repuesto",
					from: "Admin<solutions@ewin.cl>")
			end
		when 8
			@d = "122"
			@solicitud = report.dynamic_attributes.dig(@d, "value")
			@mantencion = report.dynamic_attributes.dig("121", "value")
			if  @solicitud != ""
				mail(to: 'pruebas.bild@gmail.com, cristianquilaman@pausachile.cl, carolakrebs@pausachile.cl, jorgeguerrero@pausachile.cl, lguanco@bildchile.com', subject: "PAUSA CHILE - Se generado una Solicitud de Repuesto",
					from: "Admin<solutions@ewin.cl>")
			end
		end
		return
	end

	def manflas_email(report)
		@file = File.read('./email_manflas.json')
		@json = JSON.parse(file)
		@reporte = report
		@s = "subtitle"
		@u = "assigned_user"
		if Integer(report.organization_id) == 3
			if repor.dynamic_attributes.dig(@s, "value") != nil
				@user = report.dynamic_attributes.dig(@u, "value")
				if @user != nil and @user != ""
					 @a = repor.dynamic_attributes.dig(@s, "value")
					 @a.downcase
					 @area, @category = @a.split('/')
					 Rails.logger.debug "Mails: smorales@bildchile.com #{@user[:email]} #{@json[:@area][:@category]}"
					 mail(to: 'smorales@bildchile.com' + @user[:email],
						 subject: "Manflas - Se generado un reporte", cc: @json[:@area][:@category],
						  from: "Admin<solutions@ewin.cl>")
				end
			end
		end
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

	def report_email(report_id, user, subject, message)
		report = Report.find(inspection_id)
		@user = user
		@message = message
		@url = report.default_pdf
		mail(to: @user.email, subject: subject)
	end

end
