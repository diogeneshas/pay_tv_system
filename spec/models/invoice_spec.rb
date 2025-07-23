require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:subscription) }
    it { should have_many(:invoice_accounts).dependent(:destroy) }
    it { should have_many(:accounts).through(:invoice_accounts) }
    it { should have_many(:booklet_invoices).dependent(:destroy) }
    it { should have_many(:booklets).through(:booklet_invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:due_date) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    
    it 'validates uniqueness of subscription_id scoped to due_date' do
      # Cria uma fatura para testar a validação de unicidade
      subscription = create(:subscription, :with_plan)
      create(:invoice, subscription: subscription, due_date: Date.current)
      
      # Tenta criar outra fatura com a mesma assinatura e data
      duplicate_invoice = build(:invoice, subscription: subscription, due_date: Date.current)
      
      expect(duplicate_invoice).not_to be_valid
      expect(duplicate_invoice.errors[:subscription_id]).to include('já possui uma fatura para esta data de vencimento')
    end
  end

  describe '#overdue?' do
    it 'returns true when due_date is in the past' do
      invoice = build(:invoice, due_date: 1.day.ago)
      expect(invoice.overdue?).to be true
    end

    it 'returns false when due_date is today' do
      invoice = build(:invoice, due_date: Date.current)
      expect(invoice.overdue?).to be false
    end

    it 'returns false when due_date is in the future' do
      invoice = build(:invoice, due_date: 1.day.from_now)
      expect(invoice.overdue?).to be false
    end
  end

  describe '#add_account' do
    let(:subscription) { create(:subscription, :with_plan) }
    let(:invoice) { create(:invoice, subscription: subscription) }
    let(:account) { create(:account, subscription: subscription, due_date: invoice.due_date) }

    it 'adds an account to the invoice' do
      expect { invoice.add_account(account) }.to change { invoice.accounts.count }.by(1)
    end

    it 'does not add the same account twice' do
      invoice.add_account(account)
      expect { invoice.add_account(account) }.not_to change { invoice.accounts.count }
    end
  end

  describe '#month_year' do
    it 'returns the month and year in MM/YYYY format' do
      invoice = build(:invoice, due_date: Date.new(2025, 7, 15))
      expect(invoice.month_year).to eq('07/2025')
    end
  end

  describe '#calculate_total' do
    it 'returns the sum of all associated accounts' do
      subscription = create(:subscription, :with_plan)
      invoice = create(:invoice, subscription: subscription)
      
      # Cria contas com tipos de item diferentes
      plan = create(:plan, price: 50)
      service = create(:additional_service, price: 30)
      
      account1 = create(:account, subscription: subscription, due_date: invoice.due_date, 
                      item_type: 'Plan', item_id: plan.id, amount: 50)
      account2 = create(:account, subscription: subscription, due_date: invoice.due_date, 
                      item_type: 'AdditionalService', item_id: service.id, amount: 30)
      
      invoice.add_account(account1)
      invoice.add_account(account2)
      
      expect(invoice.calculate_total).to eq(80) # 50 + 30
    end
    
    it 'returns 0 when there are no accounts' do
      subscription = create(:subscription, :with_plan)
      invoice = create(:invoice, subscription: subscription)
      expect(invoice.calculate_total).to eq(0)
    end
  end
end
