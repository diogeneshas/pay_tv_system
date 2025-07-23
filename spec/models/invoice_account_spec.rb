require 'rails_helper'

RSpec.describe InvoiceAccount, type: :model do
  describe 'associations' do
    it { should belong_to(:invoice) }
    it { should belong_to(:account) }
  end

  describe 'validations' do
    it 'validates uniqueness of account_id scoped to invoice_id' do
      subscription = create(:subscription, :with_plan)
      invoice = create(:invoice, subscription: subscription)
      account = create(:account, subscription: subscription, due_date: invoice.due_date)
      
      # Cria a primeira associação
      create(:invoice_account, invoice: invoice, account: account)
      
      # Tenta criar uma segunda associação com a mesma conta e fatura
      duplicate = build(:invoice_account, invoice: invoice, account: account)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:invoice_id]).to include('já possui esta conta associada')
    end
    
    it 'validates that invoice and account belong to the same subscription' do
      subscription1 = create(:subscription, :with_plan)
      subscription2 = create(:subscription, :with_plan)
      
      invoice = create(:invoice, subscription: subscription1)
      account = create(:account, subscription: subscription2)
      
      invoice_account = build(:invoice_account, invoice: invoice, account: account)
      
      expect(invoice_account).not_to be_valid
      expect(invoice_account.errors[:base]).to include('A fatura e a conta devem pertencer à mesma assinatura')
    end
    
    it 'validates that invoice and account have the same due date' do
      subscription = create(:subscription, :with_plan)
      invoice = create(:invoice, subscription: subscription, due_date: Date.current)
      account = create(:account, subscription: subscription, due_date: 1.day.from_now)
      
      invoice_account = build(:invoice_account, invoice: invoice, account: account)
      
      expect(invoice_account).not_to be_valid
      expect(invoice_account.errors[:base]).to include('A fatura e a conta devem ter a mesma data de vencimento')
    end
  end
end
