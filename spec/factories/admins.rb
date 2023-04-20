# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { 'admin_teste@procstudio.com.br' }
    password { '123456789' }
  end
end
