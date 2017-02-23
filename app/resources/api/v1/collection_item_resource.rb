# -*- encoding : utf-8 -*-
class Api::V1::CollectionItemResource < ApplicationResource
	attributes :name, :code
	add_foreign_keys :parent_item_id, :collection_id
	has_one :collection
	has_one :parent_item
end
