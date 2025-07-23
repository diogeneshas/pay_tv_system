class CreateBookletInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :booklet_invoices do |t|
      t.references :booklet, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
    
    # Garante que uma fatura não seja adicionada mais de uma vez a um carnê
    add_index :booklet_invoices, [:booklet_id, :invoice_id], unique: true
  end
end
