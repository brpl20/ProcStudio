# frozen_string_literal: true

FactoryBot.define do
  factory :work_event do
    description { 'Encaminhamento para o Juiz ' }
    date { 1.day.ago }
    work { create(:work) }
  end
end
