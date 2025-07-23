FactoryBot.define do
  factory :subscription_additional_service do
    association :subscription, factory: :subscription_with_plan
    association :additional_service
    
    # Trait para criar uma associação com uma assinatura que tem pacote
    trait :with_package_subscription do
      after(:build) do |subscription_additional_service|
        # Garante que o serviço adicional não está no pacote
        package = create(:package)
        subscription = create(:subscription, plan: nil, package: package)
        subscription_additional_service.subscription = subscription
      end
    end
  end
end
