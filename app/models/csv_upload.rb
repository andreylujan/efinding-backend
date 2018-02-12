# -*- encoding : utf-8 -*-
class CsvUpload
  include ActiveModel::Model
  attr_accessor :id, :row_number, :row_data, :errors,
    :created, :changed, :success

  def meta
    meta_obj = {
      row_number: @row_number,
      row_data: @row_data,
      success: @success
    }
    if @success
      meta_obj = meta_obj.merge({
      	created: @created,
      	changed: @changed
      })
    else
      meta_obj[:errors] = @errors
    end
    meta_obj
  end
end
