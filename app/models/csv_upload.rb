class CsvUpload
  include ActiveModel::Model
  attr_accessor :id, :row_number, :row_data, :errors,
    :created, :changed, :changed_attributes, :success,
    :row_number, :row_data

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
      if @changed
      	meta_obj[:changed_attributes] = []
      end
    else
      meta_obj[:errors] = @errors
    end
    meta_obj
  end
end
