class AddFieldsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :notes, :text
    add_column :subscriptions, :start_date, :date
    add_column :subscriptions, :end_date, :date
    add_column :subscriptions, :status, :string
  end
end
