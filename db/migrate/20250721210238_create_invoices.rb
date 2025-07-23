class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :subscription, null: false, foreign_key: true
      t.date :due_date, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
    
    # Garante que não haja faturas duplicadas para o mesmo mês
    add_index :invoices, [:subscription_id, :due_date], unique: true
  end
end
