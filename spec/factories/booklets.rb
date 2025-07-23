FactoryBot.define do
  factory :booklet do
    association :subscription, factory: :subscription_with_plan_and_services
    amount { 719.88 } # 59.99 * 12
    
    trait :with_invoices do
      transient do
        invoices_count { 12 }
      end
      
      after(:create) do |booklet, evaluator|
        subscription = booklet.subscription
        date = subscription.subscription_date
        
        create_list(:invoice, evaluator.invoices_count).each_with_index do |invoice, index|
          invoice.update(
            subscription: subscription,
            due_date: date + index.months,
            amount: subscription.total_amount
          )
          
          create(:booklet_invoice, booklet: booklet, invoice: invoice)
        end
      end
    end
    
    # Factory para carnê completo com todas as 12 faturas
    factory :complete_booklet do
      with_invoices
    end
  end
end
