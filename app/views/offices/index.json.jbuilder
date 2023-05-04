# frozen_string_literal: true

json.offices @offices do |office|
  json.id office.id
  json.name office.name
  json.cnpj office.cnpj
  json.city office.city
  json.site office.site
  json.type office.office_type.description
end
