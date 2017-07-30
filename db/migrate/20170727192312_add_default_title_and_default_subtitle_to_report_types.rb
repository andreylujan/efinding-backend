# -*- encoding : utf-8 -*-
class AddDefaultTitleAndDefaultSubtitleToReportTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :report_types, :default_title, :text, null: false, default: "Sin título"
    add_column :report_types, :default_subtitle, :text, null: false, default: "Sin subtítulo"
  end
end
