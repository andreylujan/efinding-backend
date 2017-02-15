# -*- encoding : utf-8 -*-
class Api::V1::CollectionItemResource < ApplicationResource
	attributes :name
	add_foreign_keys :parent_item_id, :collection_id
end
