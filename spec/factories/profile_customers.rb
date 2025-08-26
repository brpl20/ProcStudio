# frozen_string_literal: true

# == Schema Information
#
# Table name: profile_customers
#
#  id             :bigint           not null, primary key
#  birth          :date
#  capacity       :string
#  civil_status   :string
#  cnpj           :string
#  company        :string
#  cpf            :string
#  customer_type  :string
#  deceased_at    :datetime
#  deleted_at     :datetime
#  document       :json
#  gender         :string
#  inss_password  :string
#  last_name      :string
#  mother_name    :string
#  name           :string
#  nationality    :string
#  nit            :string
#  number_benefit :string
#  profession     :string
#  rg             :string
#  status         :string           default("active"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  accountant_id  :integer
#  created_by_id  :bigint
#  customer_id    :bigint           not null
#
# Indexes
#
#  index_profile_customers_on_accountant_id  (accountant_id)
#  index_profile_customers_on_created_by_id  (created_by_id)
#  index_profile_customers_on_customer_id    (customer_id)
#  index_profile_customers_on_deceased_at    (deceased_at)
#  index_profile_customers_on_deleted_at     (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (customer_id => customers.id)
#
FactoryBot.define do
  factory :profile_customer do
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    customer_type { 'representative' }
    gender { 'other' }
    rg { Faker::Number.number(digits: 6) }
    cpf { '11144477735' }
    cnpj { Faker::Number.number(digits: 14) }
    nationality { 'brazilian' }
    civil_status { 'married' }
    capacity { 'able' }
    profession { Faker::Company.profession }
    company { Faker::Company.name }
    birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    mother_name { Faker::Name.name }
    number_benefit { Faker::Number.number(digits: 5) }
    status { 'active' }
    document { '' }
    nit { Faker::Number.number(digits: 5) }
    inss_password { Faker::Number.number(digits: 5) }
    customer
    addresses { [build(:address)] }
  end
end
