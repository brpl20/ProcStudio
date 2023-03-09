# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address) { create(:address) }

  describe 'Casos de sucesso:' do
    context 'cria endereço novo:' do
      it 'Salva usuário.' do
        expect { address.save! }.not_to raise_error
      end

      it 'objeto válido' do
        expect { address.valid? }.to be_valid
      end
    end
  end
end
