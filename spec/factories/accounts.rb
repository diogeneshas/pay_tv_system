FactoryBot.define do
  factory :account do
    association :subscription, factory: :subscription_with_plan_and_services
    due_date { Date.current }
    amount { 49.99 }
    
    # Por padrão, cria uma conta para um plano
    item_type { 'Plan' }
    item_id { subscription.plan_id }
    
    trait :for_plan do
      item_type { 'Plan' }
      item_id { subscription.plan_id }
    end
    
    trait :for_package do
      item_type { 'Package' }
      
      after(:build) do |account|
        if account.subscription.package_id.nil?
          account.subscription.update(plan: nil, package: create(:package))
        end
        account.item_id = account.subscription.package_id
      end
    end
    
    trait :for_additional_service do
      item_type { 'AdditionalService' }
      
      after(:build) do |account|
        service = create(:additional_service)
        create(:subscription_additional_service, subscription: account.subscription, additional_service: service)
        account.item_id = service.id
        account.amount = service.price
      end
    end
    
    trait :overdue do
      due_date { 5.days.ago }
    end
    
    trait :future do
      due_date { 5.days.from_now }
    end
  end
end
