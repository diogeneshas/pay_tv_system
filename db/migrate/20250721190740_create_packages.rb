class CreatePackages < ActiveRecord::Migration[8.0]
  def change
    create_table :packages do |t|
      t.string :name, null: false, index: true
      t.decimal :price, null: false
      t.references :plan, null: false, foreign_key: true
      t.references :additional_service, foreign_key: true

      t.timestamps
    end
  end
end
