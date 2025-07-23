class CreateInvoiceAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_accounts do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
    
    # Garante que uma conta não seja adicionada mais de uma vez a uma fatura
    add_index :invoice_accounts, [:invoice_id, :account_id], unique: true
  end
end
