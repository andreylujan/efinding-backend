# -*- encoding : utf-8 -*-
class RemoveResolutionCommentFromReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :reports, :resolution_comment, :text
  end
end
