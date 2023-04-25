require 'rails_helper'

RSpec.describe 'offices/index.json.jbuilder', type: :view do
  let(:office) { create(:office) }
  let(:admin) { create(:profile_admin) }

  before(:each) do
    assign(:offices, [office])
  end

  it 'displays the office information in JSON format' do
    render

    expect(JSON.parse(rendered)).to match_array([
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
        'office_type_id' => office.office_type_id,
        'profile_admin_id' => office.profile_admin_id,
        'admin' => {
          'id' => admin.id,
          'name' => admin.name,
          'lastname' => admin.lastname,
          'gender' => admin.gender,
          'oab' => admin.oab,
          'rg' => admin.rg,
          'cpf' => admin.cpf,
          'nationality' => admin.nationality,
          'civil_status' => admin.civil_status,
          'birth' => admin.birth.strftime('%Y-%m-%d'),
          'mother_name' => admin.mother_name,
          'status' => admin.status,
          'admin_id' => admin.admin_id
        }
      }
    ])
  end
end
