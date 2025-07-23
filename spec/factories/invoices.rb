FactoryBot.define do
  factory :invoice do
    association :subscription, factory: :subscription_with_plan_and_services
    sequence(:due_date) { |n| Date.current + n.days } # Garante datas únicas para cada fatura
    amount { 59.99 }
    
    trait :overdue do
      due_date { 5.days.ago }
    end
    
    trait :future do
      due_date { 5.days.from_now }
    end
    
    trait :with_accounts do
      transient do
        accounts_count { 2 }
      end
      
      after(:create) do |invoice, evaluator|
        create_list(:account, evaluator.accounts_count, subscription: invoice.subscription, due_date: invoice.due_date).each do |account|
          create(:invoice_account, invoice: invoice, account: account)
        end
      end
    end
  end
end
