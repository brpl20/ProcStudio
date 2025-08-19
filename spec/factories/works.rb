# frozen_string_literal: true

# == Schema Information
#
# Table name: works
#
#  id                                                                   :bigint           not null, primary key
#  bachelor                                                             :integer
#  civel_area(Civil aréas)                                              :string
#  compensations_five_years(Compensações realizadas nos últimos 5 anos) :boolean
#  compensations_service(Compensações de oficio)                        :boolean
#  deleted_at                                                           :datetime
#  extra_pending_document                                               :string
#  folder                                                               :string
#  gain_projection(Projeção de ganho)                                   :string
#  initial_atendee                                                      :integer
#  intern                                                               :integer
#  laborite_areas(Trabalhista aréas)                                    :string
#  lawsuit(Possui ação Judicial)                                        :boolean
#  note                                                                 :string
#  number                                                               :integer
#  other_description(Descrição do outro tipo de assunto)                :text
#  partner_lawyer                                                       :integer
#  physical_lawyer                                                      :integer
#  procedure                                                            :string
#  procedures                                                           :text             default([]), is an Array
#  rate_parceled_exfield                                                :string
#  responsible_lawyer                                                   :integer
#  social_security_areas(Previdênciário aréas)                          :string
#  status                                                               :string           default("in_progress")
#  subject                                                              :string
#  tributary_areas(Tributário aréas)                                    :string
#  created_at                                                           :datetime         not null
#  updated_at                                                           :datetime         not null
#  created_by_id                                                        :bigint
#  team_id                                                              :bigint           not null
#
# Indexes
#
#  index_works_on_created_by_id  (created_by_id)
#  index_works_on_deleted_at     (deleted_at)
#  index_works_on_team_id        (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (team_id => teams.id)
#
FactoryBot.define do
  factory :work do
    procedure { 'administrative' }
    subject { 'criminal' }
    number { 1 }
    folder { Faker::Lorem.word }
    initial_atendee { 6 }
    note { Faker::Lorem.word }
    extra_pending_document { 'MyString' }
    physical_lawyer { 1 }
    responsible_lawyer { 2 }
    partner_lawyer { 3 }
    intern { 4 }
    bachelor { 5 }
  end
end
