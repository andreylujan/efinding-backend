# -*- encoding : utf-8 -*-
class Api::V1::MenuItemResource < ApplicationResource
	attributes :name, :admin_path, :url_include
	add_foreign_keys :collection_id
end
