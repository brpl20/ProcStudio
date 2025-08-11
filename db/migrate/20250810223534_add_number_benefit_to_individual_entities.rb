class AddNumberBenefitToIndividualEntities < ActiveRecord::Migration[7.0]
  def change
    add_column :individual_entities, :number_benefit, :string
  end
end
