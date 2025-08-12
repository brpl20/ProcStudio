FactoryBot.define do
  factory :system_setting do
    key { SystemSetting::MINIMUM_WAGE }
    value { 1320.00 }
    year { Date.current.year }
    description { 'Salário mínimo nacional' }
    active { true }

    trait :inss_ceiling do
      key { SystemSetting::INSS_CEILING }
      value { 7507.49 }
      description { 'Teto de contribuição do INSS' }
    end

    trait :inactive do
      active { false }
    end

    trait :previous_year do
      year { Date.current.year - 1 }
    end
  end
end
