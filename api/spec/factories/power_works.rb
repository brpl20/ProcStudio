# frozen_string_literal: true

# == Schema Information
#
# Table name: power_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  power_id   :bigint           not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_power_works_on_deleted_at  (deleted_at)
#  index_power_works_on_power_id    (power_id)
#  index_power_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (power_id => powers.id)
#  fk_rails_...  (work_id => works.id)
#
FactoryBot.define do
  factory :power_work do
    power { nil }
    work { nil }
  end
end
