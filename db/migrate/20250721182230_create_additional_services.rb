class CreateAdditionalServices < ActiveRecord::Migration[8.0]
  def change
    create_table :additional_services do |t|
      t.string :name, null: false, index: true
      t.decimal :price, default: 0.0, null: false

      t.timestamps
    end
  end
end
