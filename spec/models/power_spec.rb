# frozen_string_literal: true

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
