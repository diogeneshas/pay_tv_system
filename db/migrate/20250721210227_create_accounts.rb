class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :subscription, null: false, foreign_key: true
      t.string :item_type, null: false
      t.integer :item_id, null: false
      t.date :due_date, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
    
    add_index :accounts, [:subscription_id, :item_type, :item_id, :due_date], name: 'idx_accounts_unique_item'
  end
end
