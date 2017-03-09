# -*- encoding : utf-8 -*-
not_found = []

data = CSV.read("db/personnel.csv", { headers: false })
data.shift
data.each do |row|
	code = row[1].strip.upcase
	construction = Construction.find_by_code(code)
	nombre_admin = row[4].strip
	rut_admin = row[5].strip.upcase
	email_admin = row[6].strip.downcase
	nombre_jefe = row[7].strip
	rut_jefe = row[8].strip.upcase
	email_jefe = row[9].strip.downcase
	nombre_super = row[10].strip
	rut_super = row[11].strip.upcase
	email_super = row[12].strip.downcase
	nombre_experto = row[13].strip
	rut_experto = row[14].strip.upcase
	email_experto = row[15].strip.downcase
	
	if construction.present?

		User.find_or_initialize_by(email: email_admin).tap do |admin|
			admin.first_name = nombre_admin
			admin.rut = rut_admin.upcase.gsub('.', '').gsub('-', '')
			if not admin.persisted?
				admin.password = "12345678"
			end
			admin.role_id = 4
			admin.save!
			construction.administrator = admin
		end

		Personnel.find_or_initialize_by(rut: rut_jefe.upcase.gsub('.', '').gsub('-', '')).tap do |jefe|
			jefe.name = nombre_jefe
			jefe.email = email_jefe
			jefe.organization_id = 1
			jefe.save!
			ConstructionPersonnel.find_or_create_by!(construction: construction, personnel: jefe,
				personnel_type_id: 1)
		end

		User.find_or_initialize_by(email: email_super).tap do |supervisor|
			supervisor.first_name = nombre_super
			supervisor.rut = rut_super.upcase.gsub('.', '').gsub('-', '')
			if not supervisor.persisted?
				supervisor.password = "12345678"
			end
			supervisor.role_id = 2
			supervisor.save!
			construction.supervisor = supervisor
		end

		User.find_or_initialize_by(email: email_experto).tap do |expert|
			expert.first_name = nombre_experto
			expert.rut = rut_experto.upcase.gsub('.', '').gsub('-', '')
			if not expert.persisted?
				expert.password = "12345678"
			end
			expert.role_id = 3
			expert.save!
			construction.expert = expert
		end
		
		construction.save!
		
	else
		not_found << code
	end
end

ap not_found
