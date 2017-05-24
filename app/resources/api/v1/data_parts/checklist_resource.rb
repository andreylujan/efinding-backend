class Api::V1::DataParts::ChecklistResource < Api::V1::DataPartResource
  def type
  	@model.type.demodulize
  end
end
