FactoryBot.define do
  factory :package do
    name { "MyString" }
    price { 19.99 }
    plan { create(:plan) }
    additional_service { create(:additional_service) }

    trait :without_price do
      price { nil }
    end
  end
end
