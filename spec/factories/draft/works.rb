# frozen_string_literal: true

# == Schema Information
#
# Table name: draft_works
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  work_id    :bigint           not null
#
# Indexes
#
#  index_draft_works_on_deleted_at  (deleted_at)
#  index_draft_works_on_work_id     (work_id)
#
# Foreign Keys
#
#  fk_rails_...  (work_id => works.id)
#
FactoryBot.define do
  factory :draft_work, class: 'Draft::Work' do
    name { 'Rascunho de Trabalho 1' }
    work { nil }
  end

  trait :with_work do
    work_id { create(:work).id }
  end
end
