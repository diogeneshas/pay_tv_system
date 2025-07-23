FactoryBot.define do
  factory :subscription do
    association :client
    subscription_date { Date.current }
    start_date { Date.current }
    association :plan # Por padrão, toda assinatura terá um plano para satisfazer a validação
    
    # Para evitar que o callback after_create gere o faturamento durante os testes
    # a menos que seja explicitamente testado
    after(:build) do |subscription|
      subscription.define_singleton_method(:generate_billing) {} unless subscription.respond_to?(:generate_billing)
    end
    
    trait :with_plan do
      association :plan
      package { nil }
    end
    
    trait :with_package do
      association :package
      plan { nil }
    end
    
    trait :with_additional_services do
      transient do
        additional_services_count { 2 }
      end
      
      after(:create) do |subscription, evaluator|
        create_list(:additional_service, evaluator.additional_services_count).each do |service|
          create(:subscription_additional_service, subscription: subscription, additional_service: service)
        end
      end
    end
    
    trait :with_billing do
      after(:create) do |subscription|
        subscription.singleton_class.remove_method(:generate_billing) if subscription.respond_to?(:generate_billing)
        subscription.send(:create_booklet_with_invoices_and_accounts)
      end
    end
    
    # Factory para criar uma assinatura completa com plano e serviços adicionais
    factory :subscription_with_plan_and_services do
      with_plan
      with_additional_services
    end
    
    # Factory para criar uma assinatura completa com pacote
    factory :subscription_with_package do
      with_package
    end
  end
end
