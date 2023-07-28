class CreateSubjectFieldsInWork < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :civel_area, :string, comment: 'Civil aréas'
    add_column :works, :social_security_areas, :string, comment: 'Previdênciário aréas'
    add_column :works, :laborite_areas, :string, comment: 'Trabalhista aréas'
    add_column :works, :tributary_areas, :string, comment: 'Tributário aréas'
    add_column :works, :other_description, :text, comment: 'Descrição do outro tipo de assunto'
    add_column :works, :compensations_five_years, :boolean, comment: 'Compensações realizadas nos últimos 5 anos'
    add_column :works, :compensations_service, :boolean, comment: 'Compensações de oficio'
    add_column :works, :lawsuit, :boolean, comment: 'Possui ação Judicial'
    add_column :works, :gain_projection, :string , comment: 'Projeção de ganho'
  end
end
