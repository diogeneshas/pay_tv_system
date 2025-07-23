class CreateSubscriptionAdditionalServices < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_additional_services do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :additional_service, null: false, foreign_key: true

      t.timestamps
    end
    
    # Garante que não haja serviços adicionais duplicados em uma assinatura
    add_index :subscription_additional_services, [:subscription_id, :additional_service_id], unique: true, name: 'idx_subscription_additional_services_unique'
  end
end
