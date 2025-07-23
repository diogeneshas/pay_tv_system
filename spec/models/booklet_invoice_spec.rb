require 'rails_helper'

RSpec.describe BookletInvoice, type: :model do
  describe 'associations' do
    it { should belong_to(:booklet) }
    it { should belong_to(:invoice) }
  end

  describe 'validations' do
    it 'validates uniqueness of invoice_id scoped to booklet_id' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      invoice = create(:invoice, subscription: subscription)
      
      # Cria a primeira associação
      create(:booklet_invoice, booklet: booklet, invoice: invoice)
      
      # Tenta criar uma segunda associação com a mesma fatura e carnê
      duplicate = build(:booklet_invoice, booklet: booklet, invoice: invoice)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:booklet_id]).to include('já possui esta fatura associada')
    end
    
    it 'validates that booklet and invoice belong to the same subscription' do
      subscription1 = create(:subscription, :with_plan)
      subscription2 = create(:subscription, :with_plan)
      
      booklet = create(:booklet, subscription: subscription1)
      invoice = create(:invoice, subscription: subscription2)
      
      booklet_invoice = build(:booklet_invoice, booklet: booklet, invoice: invoice)
      
      expect(booklet_invoice).not_to be_valid
      expect(booklet_invoice.errors[:base]).to include('O carnê e a fatura devem pertencer à mesma assinatura')
    end
  end
end
