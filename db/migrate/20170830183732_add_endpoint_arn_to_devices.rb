# -*- encoding : utf-8 -*-
class AddEndpointArnToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :endpoint_arn, :text
  end
end
