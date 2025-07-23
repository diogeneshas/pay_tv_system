require 'rails_helper'

RSpec.describe SubscriptionAdditionalService, type: :model do
  describe 'associations' do
    it { should belong_to(:subscription) }
    it { should belong_to(:additional_service) }
  end

  describe 'validations' do
    it 'validates uniqueness of additional_service scoped to subscription' do
      subscription = create(:subscription, :with_plan)
      additional_service = create(:additional_service)
      
      # Cria a primeira associação
      create(:subscription_additional_service, subscription: subscription, additional_service: additional_service)
      
      # Tenta criar uma segunda associação com o mesmo serviço adicional
      duplicate = build(:subscription_additional_service, subscription: subscription, additional_service: additional_service)
      
      expect(duplicate).not_to be_valid
    end
    
    context 'when subscription has a package' do
      it 'validates that additional service is not already in the package' do
        additional_service = create(:additional_service)
        package = create(:package, additional_service: additional_service)
        subscription = create(:subscription, plan: nil, package: package)
        
        subscription_additional_service = build(:subscription_additional_service, 
          subscription: subscription, 
          additional_service: additional_service
        )
        
        expect(subscription_additional_service).not_to be_valid
        expect(subscription_additional_service.errors[:base]).to include('Este serviço adicional já está presente no pacote')
      end
      
      it 'is valid when additional service is not in the package' do
        package = create(:package)
        subscription = create(:subscription, plan: nil, package: package)
        different_additional_service = create(:additional_service)
        
        subscription_additional_service = build(:subscription_additional_service, 
          subscription: subscription, 
          additional_service: different_additional_service
        )
        
        expect(subscription_additional_service).to be_valid
      end
    end
  end
end
