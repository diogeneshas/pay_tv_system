class CreateBooklets < ActiveRecord::Migration[8.0]
  def change
    create_table :booklets do |t|
      t.references :subscription, null: false, foreign_key: true, index: { unique: true }
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
