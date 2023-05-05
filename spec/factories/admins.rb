# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { 'admin_teste@procstudio.com.br' }
    password { '123456789' }

    after(:create) do |admin|
      exp = Time.now.to_i + 24 * 3600
      token = JWT.encode({ admin_id: admin.id, exp: exp }, Rails.application.secret_key_base)
      admin.update(jwt_token: token)
    end
  end
end
