# -*- encoding : utf-8 -*-
uri = URI('http://home.moller.cl/gw-ssoma/obras.pl')
req = Net::HTTP::Get.new(uri)
req['Authorization'] = 'Basic ZUZpbmRpbmc6dkF2JC0kQVN3QWNIVWthdHUtMnU='

res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
end
codigos = []

case res
when Net::HTTPSuccess, Net::HTTPRedirection
  constructions = []
  doc = Nokogiri::XML.parse(res.body) { |config| config.noblanks }

  doc.xpath("//Obra").each do |construction|
    construction_json = {}
    construction_json[:codigo] = construction.at_css("Codigo").text
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
    company = Company.find_or_initialize_by(organization_id: 1, rut: construction_json[:company][:rut]).tap do |company|
      company.name = construction_json[:company][:name]
    end
    company.save!

    construction = Construction.find_or_initialize_by(code: construction_json[:codigo], company: company).tap do |cons|
      cons.name = construction_json[:name]
    end
    construction.save!

    if construction_json[:administrator].present?
      administrator = Person.find_or_initialize_by(rut: construction_json[:administrator][:rut]).tap do |admin|
        admin.name = construction_json[:administrator][:name]
      end
      administrator.save!
      construction.update_attributes! administrator: administrator
    end

    if construction_json[:visitor].present?
      visitor = Person.find_or_initialize_by(rut: construction_json[:visitor][:rut]).tap do |vis|
        vis.name = construction_json[:visitor][:name]
      end
      visitor.save!
      construction.update_attributes! visitor: visitor
    end

    construction.contractors = []
    construction_json[:contractors].each do |contractor_json|
      contractor = Contractor.find_or_initialize_by(rut: contractor_json[:rut],
          organization_id: 1).tap do |cont|
        cont.name = contractor_json[:name]
      end
      contractor.save!
      construction.contractors << contractor
    end

  end
else
  ap res.body
end
