# -*- encoding : utf-8 -*-
class Api::V1::CsvController < ApplicationController

  before_action :doorkeeper_authorize!
  require 'charlock_holmes'

  def create
    resource_type = params.require(:type)
    csv_file = params.require(:csv)
    contents = csv_file.read
    upload = BatchUpload.create! user: current_user, uploaded_file: csv_file,
      uploaded_resource_type: resource_type

    detection = CharlockHolmes::EncodingDetector.detect(contents)
    contents.force_encoding detection[:encoding]
    contents.encode! "UTF-8"
    organization = current_user.organization
    begin
      csv = CSV.parse(contents, { headers: true, encoding: "UTF-8", col_sep: organization.csv_separator })
    rescue => exception
      render json: {
        errors: [
          status: '400',
          detail: exception.class.to_s + ": " + exception.message
        ]
      }, status: :bad_request
      return
    end


    resource_name = "#{resource_type.to_s.underscore.singularize}".camelize

    if csv.length == 0
      render json: {
        errors: [
          status: '400',
          detail: "El CSV no incluye datos"
        ]
      }, status: :bad_request
      return
    end

    if params[:namespace]
      namespace = "#{params[:namespace].to_s.underscore.singularize}".camelize
      resource_name = "#{namespace}::#{resource_name}"
    end



    resource = resource_name.safe_constantize

    if resource.nil?
      render json: {
        errors: [
          status: '400',
          detail: "El tipo #{resource_type} es inválido"
        ]
      }, status: :bad_request
      return
    end

    keys = csv.first.to_hash.keys

    keys.each do |k|
      if not resource.new.respond_to?(k.to_s.strip + "=")
        render json: {
          errors: [
            status: '400',
            detail: "La columna #{k} es inválida para el maestro #{resource_type}"
          ]
        }, status: :bad_request
        return
      end
    end

    resources = []
    augmented_params = context.select do |k, v|
      resource.new.respond_to?(k.to_s + "=")
    end
    csv.each do |row|
      row_hash = row.to_hash
      stripped_hash = {}
      row_hash.each do |k, v|
        stripped_hash[k.to_s.strip] = row_hash[k]
      end
      create_params = augmented_params.merge(stripped_hash)
      create_params.each { |k, v| if v.is_a? String then create_params[k.to_s] = v.strip end }
      resources << create_params
    end

    errors = []

    if resource.respond_to? :transaction
      resource.transaction do
        errors = do_transaction(csv, resource, resources, upload)
      end
    else
      errors = do_transaction(csv, resource, resources, upload)
    end
    # resource.transaction do

    # end


    return_json = {
      data: errors
    }

    render json: return_json
  end

  def do_transaction(csv, resource, resources, upload)

    created_resources = []
    exceptions = []
    errors = []

    num_headers = csv.headers.length


    if resource.respond_to? :csv_findable_keys
      resources.each_with_index do | r, index |



        selected = r.select { |key, value| resource.csv_findable_keys.include? key }
        if resource.respond_to? :with_deleted
          lookup = resource.with_deleted.find_by(selected)
        else
          lookup = resource.where(selected).first
        end

        if lookup.nil?
          begin
            created_resources << resource.create(r)
          rescue => exception
            reduced_headers = r.select do |k, v|
              resource.new.respond_to? k
            end
            new_resource = resource.new reduced_headers
            if num_headers < r.length
              new_resource.errors.add(:"Número de columnas", "Esta fila tiene más columnas que el número de cabeceras")
            else
              new_resource.errors.add(exception.class.to_s.split(":")[-1], exception.message)
            end
            created_resources << new_resource
          end
        else
          if lookup.respond_to? :restore and lookup.respond_to? :deleted_at and lookup.deleted_at.present?
            lookup.restore
          elsif lookup.respond_to? :deleted_at and lookup.deleted_at.present?
            lookup.update_attribute :deleted_at, nil
          end
          begin
            lookup.update_attributes(r)
            created_resources << lookup
          rescue => exception
            if num_headers < r.length
              lookup.errors.add(:"Número de columnas", "Esta fila tiene más columnas que el número de cabeceras")
            else
              lookup.errors.add(exception.class.to_s.split(":")[-1], exception.message)
            end
            created_resources << lookup
          end

        end
      end
    else
      resources.each do |resource_hash|
        begin
          created_resources << (resource.create resource_hash)
        rescue => exception
          reduced_headers = resource_hash.select do |k, v|
            resource.new.respond_to? k
          end
          new_resource = resource.new reduced_headers
          if num_headers < resource_hash.length
            new_resource.errors.add(:"Número de columnas", "Esta fila tiene más columnas que el número de cabeceras")
          else
            new_resource.errors.add(exception.class.to_s.split(":")[-1], exception.message)
          end
          created_resources << new_resource
        end
      end
    end

    Tempfile.open(['result', '.csv']) do |fh|
      result_csv = CSV.new(fh)
      headers = resource.attribute_names.clone
      headers.unshift('Resultado carga')
      created_ids = []
      result_csv << headers
      created_resources.each_with_index do | val, index |
        data = {
          id: (index + 1).to_s,
          type: "csv",
          meta: {
            row_number: index + 1,
            row_data: csv[index].to_hash
          }
        }
        if not val.class < ActiveRecord::Base and not val.class < Mongoid::Document

          data[:meta][:success] = false
          message = val.class < Exception ? val.message : val.to_s
          result_csv << ([ message ])
          data[:meta][:errors] = {
            "formato fila": [
              message
            ]
          }
        elsif val.errors.any?

          result_csv << val.attributes.values.unshift(val.errors.messages.map { |k,v| k.to_s + ": " + v.join(', ') }.join(', '))
          data[:meta][:success] = false
          data[:meta][:errors] = val.errors.as_json
        else

          created_ids << val.id
          data[:meta][:success] = true

          if val.previous_changes[:id].present? or val.previous_changes[:deleted_at].present? or val.previous_changes[:_id].present?
            result_csv << val.attributes.values.unshift('Creado')
            data[:meta][:created] = true
            data[:meta][:changed] = false
          elsif val.previous_changes.any?
            result_csv << val.attributes.values.unshift('Modificado')
            data[:meta][:created] = false
            data[:meta][:changed] = true
            data[:meta][:changed_attributes] =
              val.previous_changes.keys - [ "updated_at", "created_at" ]
          else
            result_csv << val.attributes.values.unshift('Sin cambios')
            data[:meta][:created] = false
            data[:meta][:changed] = false
          end
        end
        errors << data
      end

    
      result_csv.close
      upload.result_file = fh.open
      upload.save!
      fh.close
      fh.unlink
    end

    errors
  end

  def context
    @context ||= ({
                    role_id: current_user.role_id,
                    creator_id: current_user.id
                  })
  end

end
