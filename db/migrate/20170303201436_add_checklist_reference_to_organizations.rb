# -*- encoding : utf-8 -*-
class AddChecklistReferenceToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_reference :organizations, :checklist, foreign_key: true
    Organization.all.each do |org|
      if org.checklists.count > 0
        org.checklist_id = org.checklists.first.id
        org.save!
      end
    end
  end
end
