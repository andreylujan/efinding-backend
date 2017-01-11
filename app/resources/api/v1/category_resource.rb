# -*- encoding : utf-8 -*-
class Api::V1::CategoryResource < ApplicationResource
  attributes :name

  def self.records(options = {})
    context = options[:context]
    context[:current_user].organization.categories
  end

end
