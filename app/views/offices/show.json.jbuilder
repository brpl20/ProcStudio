# frozen_string_literal: true

json.id @office.id
json.name @office.name
json.cnpj @office.cnpj
json.oab @office.oab
json.society @office.society
json.foundation @office.foundation
json.site @office.site
json.cep @office.cep
json.street @office.street
json.number @office.number
json.neighborhood @office.neighborhood
json.city @office.city
json.state @office.state

if @office.office_type.present?
  json.office_type do
    json.description @office.office_type.description
  end
end

if @office.profile_admin.present?
  json.admin do
    json.role @office.profile_admin.role
    json.name @office.profile_admin.name
    json.lastname @office.profile_admin.lastname
    json.gender @office.profile_admin.gender
    json.oab @office.profile_admin.oab
    json.rg @office.profile_admin.rg
    json.cpf @office.profile_admin.cpf
    json.nationality @office.profile_admin.nationality
    json.civil_status @office.profile_admin.civil_status
    json.birth @office.profile_admin.birth
    json.mother_name @office.profile_admin.mother_name
    json.status @office.profile_admin.status
    # json.admin office.profile_admin.admin
  end
end
