class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :client, null: false, foreign_key: true
      t.references :plan, null: true, foreign_key: true
      t.references :package, null: true, foreign_key: true
      t.date :subscription_date, null: false

      t.timestamps
    end
    
    add_index :subscriptions, [:client_id, :subscription_date]
  end
end
