# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

return unless Rails.env.development?

puts "This will delete all data in the dev database (except the Organization), do you wish to continue? [y/n]"
continue = $stdin.gets.chomp

exit(0) unless continue.downcase == 'y'

organization = Organization.first
abort("Run db/load_checklists.rb first to create the Checklist") unless organization

Role.destroy_all
role = Role.create!(id: 1, organization_id: organization.id, name: "Superusuario", role_type: "superuser")
Role.create!(id: 2, organization_id: organization.id, name: "Jefe SSOMA MPC", role_type: "supervisor")
Role.create!(id: 3, organization_id: organization.id, name: "Experto SSOMA", role_type: "expert")
Role.create!(id: 4, organization_id: organization.id, name: "Administrador de Obra", role_type: "administrator")

User.destroy_all
User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password', first_name: "Admin", role: role)
