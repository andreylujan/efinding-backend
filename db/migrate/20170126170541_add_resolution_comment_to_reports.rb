# -*- encoding : utf-8 -*-
class AddResolutionCommentToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :resolution_comment, :text
  end
end
