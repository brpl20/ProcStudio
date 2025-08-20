# frozen_string_literal: true

# == Schema Information
#
# Table name: powers
#
#  id                 :bigint           not null, primary key
#  category           :integer          not null
#  description        :string           not null
#  is_base            :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_team_id :bigint
#  law_area_id        :bigint
#
# Indexes
#
#  index_powers_on_category_and_law_area_id  (category,law_area_id)
#  index_powers_on_created_by_team_id        (created_by_team_id)
#  index_powers_on_is_base                   (is_base)
#  index_powers_on_law_area_id               (law_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_team_id => teams.id)
#  fk_rails_...  (law_area_id => law_areas.id)
#
require 'rails_helper'

RSpec.describe Power, type: :model do
  let(:power) { create(:power) }

  describe 'Casos de sucesso:' do
    context 'durante a criação:' do
      it 'salva com sucesso' do
        expect { power.save! }.not_to raise_error
      end

      it 'objeto válido' do
        expect(power).to be_valid
      end
    end
    context 'durante a alteração' do
      it 'altera descrição' do
        power.update(description: 'Trabalhista')
        expect(power.description).to eq('Trabalhista')
      end

      it 'altera categoria' do
        power.update(category: 'admspecificprev')
        expect(power.category).to eq('admspecificprev')
      end
    end
  end
end
