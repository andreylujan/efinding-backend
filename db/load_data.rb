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
  obras = []
  doc = Nokogiri::XML.parse(res.body) { |config| config.noblanks }
  
  doc.xpath("//Obra").each do |obra|
    obra_json = {}
    obra_json[:codigo] = obra.at_css("Codigo").text
    obra_json[:nombre] = obra.at_css("Nombre").text
    admin = obra.at_css("Administrador")
    visitador = obra.at_css("Visitador")
    empresa = obra.at_css("RznSocial")

    obra_json[:empresa] = {
      rut: empresa.at_css("RUT").text,
      nombre: empresa.at_css("Nombre").text
    }

    if visitador and visitador.at_css("RUT") and visitador.at_css("Nombre")
      obra_json[:visitador] = {
        rut: visitador.at_css("RUT").text,
        nombre: visitador.at_css("Nombre").text
      }
    else
      obra_json[:visitador] = nil
    end
    if admin and admin.at_css("RUT") and admin.at_css("Nombre")
      obra_json[:administrador] = {
        rut: admin.at_css("RUT").text,
        nombre: admin.at_css("Nombre").text
      }
    else
      obra_json[:administrador] = nil
    end


    contratistas = []
    obra.css("Contratista").each do |contratista|
    	contratistas << {
    		rut: contratista.at_css("RUT").text,
    		nombre: contratista.at_css("Nombre").text
    	}
    end
    # ap contratistas
    obra_json[:contratistas] = contratistas
    # ap obra_json
    # ap constratistas
    # ap obra_json
    obras << obra_json
    # ap obras
    # byebug
  end
  ap obras
  obras.each do |obra|
    construction = Construction.find_by_code(obra[:codigo])
    # ap construction
  end
else
  ap res.body
end
