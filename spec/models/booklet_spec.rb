require 'rails_helper'

RSpec.describe Booklet, type: :model do
  describe 'associations' do
    it { should belong_to(:subscription) }
    it { should have_many(:booklet_invoices).dependent(:destroy) }
    it { should have_many(:invoices).through(:booklet_invoices) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    
    it 'validates uniqueness of subscription_id' do
      subscription = create(:subscription, :with_plan)
      create(:booklet, subscription: subscription)
      
      duplicate_booklet = build(:booklet, subscription: subscription)
      
      expect(duplicate_booklet).not_to be_valid
      expect(duplicate_booklet.errors[:subscription_id]).to include('já possui um carnê')
    end
  end

  describe '#add_invoice' do
    let(:subscription) { create(:subscription, :with_plan) }
    let(:booklet) { create(:booklet, subscription: subscription) }
    let(:invoice) { create(:invoice, subscription: subscription) }

    it 'adds an invoice to the booklet' do
      expect { booklet.add_invoice(invoice) }.to change { booklet.invoices.count }.by(1)
    end

    it 'does not add the same invoice twice' do
      booklet.add_invoice(invoice)
      expect { booklet.add_invoice(invoice) }.not_to change { booklet.invoices.count }
    end
  end

  describe '#invoice_count' do
    it 'returns the number of invoices in the booklet' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      
      # Cria faturas com datas únicas manualmente
      invoice1 = create(:invoice, subscription: subscription, due_date: Date.current + 1.day)
      invoice2 = create(:invoice, subscription: subscription, due_date: Date.current + 2.days)
      invoice3 = create(:invoice, subscription: subscription, due_date: Date.current + 3.days)
      
      booklet.add_invoice(invoice1)
      booklet.add_invoice(invoice2)
      booklet.add_invoice(invoice3)
      
      expect(booklet.invoice_count).to eq(3)
    end
  end

  describe '#ordered_invoices' do
    it 'returns invoices ordered by due_date' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      invoice1 = create(:invoice, subscription: subscription, due_date: 3.days.from_now)
      invoice2 = create(:invoice, subscription: subscription, due_date: 1.day.from_now)
      invoice3 = create(:invoice, subscription: subscription, due_date: 2.days.from_now)
      
      booklet.add_invoice(invoice1)
      booklet.add_invoice(invoice2)
      booklet.add_invoice(invoice3)
      
      ordered_invoices = booklet.ordered_invoices
      
      expect(ordered_invoices.to_a).to eq([invoice2, invoice3, invoice1])
    end
  end

  describe '#complete?' do
    it 'returns true when there are 12 invoices' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      
      # Cria 12 faturas com datas únicas manualmente
      12.times do |i|
        invoice = create(:invoice, subscription: subscription, due_date: Date.current + i.days)
        booklet.add_invoice(invoice)
      end
      
      expect(booklet.complete?).to be true
    end

    it 'returns false when there are less than 12 invoices' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      
      # Cria 11 faturas com datas únicas manualmente
      11.times do |i|
        invoice = create(:invoice, subscription: subscription, due_date: Date.current + i.days)
        booklet.add_invoice(invoice)
      end
      
      expect(booklet.complete?).to be false
    end
  end

  describe '#calculate_total' do
    it 'returns the sum of all associated invoices' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      invoice1 = create(:invoice, subscription: subscription, amount: 100, due_date: Date.current + 1.day)
      invoice2 = create(:invoice, subscription: subscription, amount: 150, due_date: Date.current + 2.days)
      
      booklet.add_invoice(invoice1)
      booklet.add_invoice(invoice2)
      
      expect(booklet.calculate_total).to eq(250) # 100 + 150
    end
    
    it 'returns 0 when there are no invoices' do
      subscription = create(:subscription, :with_plan)
      booklet = create(:booklet, subscription: subscription)
      expect(booklet.calculate_total).to eq(0)
    end
  end
end
