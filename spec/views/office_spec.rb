# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET offices/index.json.jbuilder', type: :view do
  let(:office) { create(:office) }

  before do
    assign(:offices, [office])
  end

  it 'Mostra o office no formato JSON' do
    render
    expect(JSON.parse(rendered)).to match_array(
      'offices' => [
        {
          'id' => office.id,
          'name' => office.name,
          'cnpj' => office.cnpj,
          'oab' => office.oab,
          'society' => office.society,
          'foundation' => office.foundation,
          'site' => office.site,
          'cep' => office.cep,
          'street' => office.street,
          'number' => office.number,
          'neighborhood' => office.neighborhood,
          'city' => office.city,
          'state' => office.state,
          'office_type' => {
            'description': office.office_type.description
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
    )
  end
end
