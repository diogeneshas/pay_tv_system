require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { should belong_to(:subscription) }
    it { should have_many(:invoice_accounts).dependent(:destroy) }
    it { should have_many(:invoices).through(:invoice_accounts) }
  end

  describe 'validations' do
    it { should validate_presence_of(:item_type) }
    it { should validate_presence_of(:item_id) }
    it { should validate_presence_of(:due_date) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    
    it 'validates uniqueness of item scoped to subscription_id and due_date' do
      subscription = create(:subscription, :with_plan)
      plan = subscription.plan
      
      # Cria a primeira conta
      create(:account, 
        subscription: subscription, 
        item_type: 'Plan', 
        item_id: plan.id, 
        due_date: Date.current
      )
      
      # Tenta criar outra conta para o mesmo item na mesma data
      duplicate = build(:account, 
        subscription: subscription, 
        item_type: 'Plan', 
        item_id: plan.id, 
        due_date: Date.current
      )
      
      expect(duplicate).not_to be_valid
    end
  end

  describe '#item' do
    context 'when item_type is Plan' do
      it 'returns the associated plan' do
        plan = create(:plan)
        account = create(:account, :for_plan, item_id: plan.id)
        
        expect(account.item).to eq(plan)
      end
    end
    
    context 'when item_type is Package' do
      it 'returns the associated package' do
        package = create(:package)
        account = build(:account, item_type: 'Package', item_id: package.id)
        
        expect(account.item).to eq(package)
      end
    end
    
    context 'when item_type is AdditionalService' do
      it 'returns the associated additional service' do
        service = create(:additional_service)
        account = create(:account, item_type: 'AdditionalService', item_id: service.id)
        
        expect(account.item).to eq(service)
      end
    end
  end

  describe '#overdue?' do
    it 'returns true when due_date is in the past' do
      account = build(:account, due_date: 1.day.ago)
      expect(account.overdue?).to be true
    end

    it 'returns false when due_date is today' do
      account = build(:account, due_date: Date.current)
      expect(account.overdue?).to be false
    end

    it 'returns false when due_date is in the future' do
      account = build(:account, due_date: 1.day.from_now)
      expect(account.overdue?).to be false
    end
  end
end
