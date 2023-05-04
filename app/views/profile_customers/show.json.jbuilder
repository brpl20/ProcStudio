# frozen_string_literal: true

json.type @profile_customer.type
json.name @profile_customer.name
json.lastname @profile_customer.lastname
json.gender @profile_customer.gender
json.rg @profile_customer.rg
json.cpf @profile_customer.cpf
json.cnpj @profile_customer.cnpj
json.nationality @profile_customer.nationality
json.civil_status @profile_customer.civil_status
json.capacity @profile_customer.capacity
json.profession @profile_customer.profession
json.company @profile_customer.company
json.birth @profile_customer.birth
json.mother_name @profile_customer.mother_name
json.number_benefit @profile_customer.number_benefit
json.status @profile_customer.status
json.document @profile_customer.document
json.nit @profile_customer.nit
json.inss_password @profile_customer.inss_password
json.invalid_person @profile_customer.invalid_person

json.addresses @profile_customer.addresses do |ad|
  json.description ad.description
  json.zip_code ad.zip_code
  json.street ad.street
  json.number ad.number
  json.neighborhood ad.neighborhood
  json.city ad.city
  json.state ad.state
end

json.bank_accounts @profile_customer.bank_accounts do |ba|
  json.bank ba.bank_name
  json.state ba.type_account
  json.agency ba.agency
  json.account ba.account
  json.operation ba.operation
end

json.emails @profile_customer.emails do |e|
  json.email e.email
end

json.phones @profile_customer.phones do |ph|
  json.phone ph.phone
end
