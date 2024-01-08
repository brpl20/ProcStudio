# frozen_string_literal: true

FactoryBot.define do
  factory :draft_work, class: 'Draft::Work' do
    name { 'Rascunho de Trabalho 1' }
    work { nil }
  end
end
