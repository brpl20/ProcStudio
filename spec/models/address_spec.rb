# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:address) { create(:address) }

  describe 'Casos de sucesso:' do
    context 'com usuário logado:' do
      it 'Salva usuário.' do
        expect { address.save! }.not_to raise_error
      end
    end
  end
end
