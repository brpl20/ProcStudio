# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'offices/index.json.jbuilder', type: :view do
  let(:office) { create(:office) }

  describe 'GET /api/v1/offices' do
    before do
      assign(:offices, [office])
    end

    context 'Retorno do JSON' do
      it 'Mostra o office no formato JSON' do
        render
        expected_result = {
          'offices' => [
            {
              'id' => office.id,
              'name' => office.name,
              'cnpj' => office.cnpj,
              'oab' => office.oab,
              'society' => office.society,
              'foundation' => office.foundation.to_s,
              'site' => office.site,
              'cep' => office.cep,
              'street' => office.street,
              'number' => office.number,
              'neighborhood' => office.neighborhood,
              'city' => office.city,
              'state' => office.state,
              'office_type' => {
                'description' => office.office_type.description
              },
              'admin' => {
                'name' => office.profile_admin.name,
                'lastname' => office.profile_admin.lastname,
                'gender' => office.profile_admin.gender,
                'role' => office.profile_admin.role,
                'oab' => office.profile_admin.oab,
                'status' => office.profile_admin.status
              }
            }
          ]
        }

        expect(JSON.parse(rendered)).to eq(expected_result.as_json)
      end
    end
  end
end
