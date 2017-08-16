# -*- encoding : utf-8 -*-

require 'digest'
old_md5sum = nil
if File.file? ENV['MD5SUM_FILE']
  f = File.open(ENV['MD5SUM_FILE'], 'r')
  old_md5sum = f.read
  f.close
end

md5sum = Digest::MD5.file(ENV['DATA_FILE']).hexdigest
if not old_md5sum.nil? and old_md5sum == md5sum
  exit
end

require 'csv'
def titleize(word)
  word.humanize.gsub(/\b(?<!['’`])[a-z]/) { $&.capitalize }
end

CollectionItem.transaction do

  # Contact.destroy_all
  # Construction.destroy_all
  # Client.destroy_all

  CSV.foreach(ENV['DATA_FILE'], { col_sep: ';', encoding: 'windows-1251:utf-8' }) do |row|
    if row.length >= 4
      client_data = {
        rut: row[0],
        name: row[1],
        construction_name: row[2],
        construction_id: row[3]
      }
      if row.length >= 5
        client_data[:contact_name] = row[4]
      end

      if row.length >= 6
        client_data[:contact_email] = row[5]
      end

      if row.length >= 7
        client_data[:construction_address] = row[6]
      end

      client_data.values.each do |val|
        val.strip! if val.present?
      end

      if client_data[:rut].nil? or client_data[:construction_id].nil? or
        /(\d)+-./.match(client_data[:rut]).nil?
        # ap client_data
        next
      end
      client_data[:rut].upcase!
      client_data[:contact_email].downcase! if client_data[:contact_email].present?
      client_data[:name] = titleize(client_data[:name]) if client_data[:name].present?
      client_data[:construction_name] = titleize(client_data[:construction_name]) if client_data[:construction_name].present?
      client_data[:construction_id] = client_data[:construction_id].to_i
      client_data[:construction_address] = titleize(client_data[:construction_address]) if client_data[:construction_address].present?
      client_data[:contact_name] = titleize(client_data[:contact_name]) if client_data[:contact_name].present?
      
      collection = Collection.find(27)
      construction = collection.collection_items.find_by_code(client_data[:rut])
      if construction.present?
        if construction.parent_item.nil?
          construction.parent_item_id = 834
        end
        construction.name = "#{client_data[:name]}"
        construction.save!
      else
        collection.collection_items.create!(code: client_data[:rut], name: client_data[:name], parent_item_id: 834)
      end
    end
  end
end

f = File.open(ENV['MD5SUM_FILE'], 'w')
f.write md5sum
f.close
