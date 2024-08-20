# frozen_string_literal: true

FactoryBot.define do
  factory :draft_work, class: 'Draft::Work' do
    name { 'Rascunho de Trabalho 1' }
    work { nil }
  end

  trait :with_work do
    work_id { create(:work).id }
  end
end
