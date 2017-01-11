class Api::V1::BatchUploadResource < ApplicationResource
	has_one :user
	attributes :uploaded_resource_type, :uploaded_file_url, :uploaded_file_size, :result_file_url, :result_file_size, :created_at

	def self.records(options = {})
    	context = options[:context]
    	BatchUpload.joins(user: :role).where(roles: { organization_id: context[:current_user].organization_id })    	
  	end
end
