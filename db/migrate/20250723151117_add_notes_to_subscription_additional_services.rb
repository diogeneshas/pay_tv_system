class AddNotesToSubscriptionAdditionalServices < ActiveRecord::Migration[8.0]
  def change
    add_column :subscription_additional_services, :notes, :text
  end
end
