# -*- encoding : utf-8 -*-
url = 'http://home.moller.cl/gw-ssoma/obras.pl'
uri = URI(url)
req = Net::HTTP::Get.new(uri)
req['Authorization'] = 'Basic ZUZpbmRpbmc6dkF2JC0kQVN3QWNIVWthdHUtMnU='


log = RequestLog.new organization_id: 1, url: url, error_messages: []

begin
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
rescue => exception
  log.error_messages << exception.message
  log.save!
end

require 'charlock_holmes'

body = res.body
detection = CharlockHolmes::EncodingDetector.detect(body)
body.force_encoding detection[:encoding]
body.encode! "UTF-8"

codigos = []
log.response_body = body
log.status_code = res.code
log.save!

if not res.is_a? Net::HTTPSuccess and not res.is_a? Net::HTTPRedirection
  body = RequestLog.where(status_code: 200).order('created_at DESC').first.response_body
  detection = CharlockHolmes::EncodingDetector.detect(body)
  body.force_encoding detection[:encoding]
  body.encode! "UTF-8"
end

constructions = []
doc = Nokogiri::XML.parse(body, nil, "UTF-8") { |config| config.noblanks }

doc.xpath("//Obra").each do |construction|
  construction_json = {}
  construction_json[:codigo] = construction.at_css("Codigo").text.upcase
  construction_json[:name] = construction.at_css("Nombre").text
  admin = construction.at_css("Administrador")
  visitor = construction.at_css("Visitador")
  company = construction.at_css("RznSocial")

  construction_json[:company] = {
    rut: company.at_css("RUT").text,
    name: company.at_css("Nombre").text
  }

  if visitor and visitor.at_css("RUT") and visitor.at_css("Nombre")
    construction_json[:visitor] = {
      rut: visitor.at_css("RUT").text,
      name: visitor.at_css("Nombre").text
    }
  else
    construction_json[:visitor] = nil
  end
  if admin and admin.at_css("RUT") and admin.at_css("Nombre")
    construction_json[:administrator] = {
      rut: admin.at_css("RUT").text,
      name: admin.at_css("Nombre").text
    }
  else
    construction_json[:administrator] = nil
  end


  contractors = []
  construction.css("Contratista").each do |contractor|
    contractors << {
      rut: contractor.at_css("RUT").text,
      name: contractor.at_css("Nombre").text
    }
  end
  # ap contractors
  construction_json[:contractors] = contractors
  # ap construction_json
  # ap constratistas
  # ap construction_json
  constructions << construction_json
  # ap constructions
  # byebug
end
# ap constructions
constructions.each do |construction_json|
  company_rut = construction_json[:company][:rut]
  if RUT::validar(company_rut)
    company_rut = RUT::formatear(RUT::quitarFormato(company_rut).gsub(/^0+|$/, '')).upcase
  end
  company = Company.find_or_initialize_by(organization_id: 1, rut: company_rut).tap do |company|
    company.name = construction_json[:company][:name]
  end
  company.save!

  construction = Construction.find_or_initialize_by(code: construction_json[:codigo], company: company).tap do |cons|
    cons.name = construction_json[:name]
  end
  construction.save!

  if construction_json[:administrator].present?
    admin_rut = construction_json[:administrator][:rut]
    if RUT::validar(admin_rut)
      admin_rut = RUT::formatear(RUT::quitarFormato(admin_rut).gsub(/^0+|$/, '')).upcase
    end
    administrator = User.find_by(rut: admin_rut)
    if administrator.present?
      administrator.save!
      construction.update_attributes! administrator: administrator
    end
  end

  if construction_json[:visitor].present?
    personnel_rut = construction_json[:visitor][:rut]
    if RUT::validar(personnel_rut)
      personnel_rut = RUT::formatear(RUT::quitarFormato(personnel_rut).gsub(/^0+|$/, '')).upcase
    end
    Personnel.find_or_initialize_by(rut: personnel_rut) do |visitor|
      visitor.name = construction_json[:visitor][:name]
      visitor.organization_id = 1
      visitor.save!
      ConstructionPersonnel.find_or_create_by!(personnel_type_id: 2, personnel: visitor, construction:
                                               construction)
    end
  end

  construction.contractors = []
  construction_json[:contractors].each do |contractor_json|
    contractor_rut = contractor_json[:rut]
    if RUT::validar(contractor_rut)
      contractor_rut = RUT::formatear(RUT::quitarFormato(contractor_rut).gsub(/^0+|$/, '')).upcase
    end
    contractor = Contractor.find_or_initialize_by(rut: contractor_rut,
    organization_id: 1).tap do |cont|
      cont.name = contractor_json[:name]
    end
    contractor.save!
    construction.contractors << contractor
  end
end
