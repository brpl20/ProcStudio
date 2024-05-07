FactoryBot.define do
  factory :work_event do
    status { 'in_progress' }
    description { 'Encaminhamento para o Juiz ' }
    date { 1.day.ago }
    work { create(:work) }
  end
end
