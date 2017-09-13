# -*- encoding : utf-8 -*-
class Api::V1::AppMenuItemResource < ApplicationResource
	add_foreign_keys :organization_id
	attributes :name, :url_include, :filter_assigned_user,
		:filter_creator, :icon
end
