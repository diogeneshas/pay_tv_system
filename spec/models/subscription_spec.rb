require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations' do
    it { should belong_to(:client) }
    it { should belong_to(:plan).optional }
    it { should belong_to(:package).optional }
    it { should have_many(:subscription_additional_services).dependent(:destroy) }
    it { should have_many(:additional_services).through(:subscription_additional_services) }
    it { should have_many(:accounts).dependent(:destroy) }
    it { should have_many(:invoices).dependent(:destroy) }
    it { should have_one(:booklet).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subscription_date) }
    
    context 'plan or package presence' do
      let(:client) { create(:client) }
      let(:plan) { create(:plan) }
      let(:package) { create(:package) }
      
      it 'is valid with a plan' do
        subscription = build(:subscription, client: client, plan: plan, package: nil)
        expect(subscription).to be_valid
      end
      
      it 'is valid with a package' do
        subscription = build(:subscription, client: client, plan: nil, package: package)
        expect(subscription).to be_valid
      end
      
      it 'is invalid without both plan and package' do
        subscription = build(:subscription, client: client, plan: nil, package: nil)
        expect(subscription).not_to be_valid
        expect(subscription.errors[:base]).to include('A assinatura deve ter pelo menos um plano ou pacote')
      end
      
      it 'is invalid with both plan and package' do
        subscription = build(:subscription, client: client, plan: plan, package: package)
        expect(subscription).not_to be_valid
        expect(subscription.errors[:base]).to include('A assinatura não pode ter plano e pacote ao mesmo tempo')
      end
    end
    
    context 'additional services' do
      let(:client) { create(:client) }
      let(:plan) { create(:plan) }
      let(:additional_service) { create(:additional_service) }
      let(:package_with_service) { create(:package, additional_service: additional_service) }
      
      it 'validates that no duplicate additional services are present' do
        subscription = create(:subscription, client: client, plan: plan)
        subscription.additional_services << additional_service
        
        # Tenta adicionar o mesmo serviço novamente
        expect { subscription.additional_services << additional_service }.to raise_error(ActiveRecord::RecordInvalid)
      end
      
      it 'validates that no additional services are allowed with package' do
        subscription = build(:subscription, client: client, package: package_with_service)
        subscription.additional_services << additional_service
        
        expect(subscription).not_to be_valid
        expect(subscription.errors[:additional_services]).to include('não podem ser adicionados quando a assinatura é por pacote')
      end
    end
  end

  describe 'callbacks' do
    context 'after_create' do
      it 'generates billing' do
        client = create(:client)
        plan = create(:plan)
        
        subscription = build(:subscription, client: client, plan: plan, subscription_date: Date.current, start_date: Date.current)
        
        expect(subscription).to receive(:generate_billing)
        subscription.save
      end
    end
  end

  describe '#total_amount' do
    let(:client) { create(:client) }
    let(:plan) { create(:plan, price: 50) }
    let(:additional_service1) { create(:additional_service, price: 10) }
    let(:additional_service2) { create(:additional_service, price: 15) }
    
    it 'returns the sum of plan price and additional services prices' do
      subscription = create(:subscription, client: client, plan: plan, package: nil)
      subscription.additional_services << [additional_service1, additional_service2]
      
      expect(subscription.total_amount).to eq(75) # 50 + 10 + 15
    end
    
    it 'returns only the package price when subscription is by package' do
      package = create(:package, price: 60)
      subscription = create(:subscription, client: client, package: package, plan: nil)
      
      # Não adicionamos serviços adicionais porque não são permitidos com pacote
      expect(subscription.total_amount).to eq(60) # Apenas o preço do pacote
    end
  end

  describe '#create_booklet_with_invoices_and_accounts' do
    let(:client) { create(:client) }
    let(:plan) { create(:plan, price: 50) }
    let(:additional_service) { create(:additional_service, price: 10) }
    let(:subscription_date) { Date.new(2025, 7, 15) } # Data fixa para testes
    let(:start_date) { Date.new(2025, 7, 15) } # Data fixa para testes
    
    before do
      # Desabilita temporariamente o callback after_create para testar manualmente
      Subscription.skip_callback(:create, :after, :generate_billing)
    end
    
    after do
      # Reativa o callback para outros testes
      Subscription.set_callback(:create, :after, :generate_billing)
    end
    
    it 'creates a booklet with 12 invoices and respective accounts' do
      subscription = create(:subscription, client: client, plan: plan, subscription_date: subscription_date, start_date: start_date)
      subscription.additional_services << additional_service
      
      # Chama o método manualmente
      subscription.send(:create_booklet_with_invoices_and_accounts)
      
      # Verifica se o carnê foi criado
      expect(subscription.booklet).to be_present
      expect(subscription.booklet.amount).to eq(60 * 12) # (50 + 10) * 12
      expect(subscription.booklet.created_at).to be_present
      
      # Verifica se as faturas foram criadas
      expect(subscription.invoices.count).to eq(12)
      
      # Verifica se as contas foram criadas para cada fatura
      invoice = subscription.invoices.first
      expect(invoice.accounts.count).to eq(2) # Uma para o plano e uma para o serviço adicional
      
      # Verifica se as contas têm os valores corretos
      plan_account = invoice.accounts.find_by(item_type: 'Plan')
      service_account = invoice.accounts.find_by(item_type: 'AdditionalService')
      
      expect(plan_account.amount).to eq(50)
      expect(service_account.amount).to eq(10)
      expect(plan_account.created_at).to be_present
      expect(service_account.created_at).to be_present
    end
    
    it 'sets correct due dates for all invoices' do
      subscription = create(:subscription, client: client, plan: plan, subscription_date: subscription_date, start_date: start_date)
      
      # Chama o método manualmente
      subscription.send(:create_booklet_with_invoices_and_accounts)
      
      # Ordena as faturas por data de vencimento
      invoices = subscription.invoices.order(:due_date)
      
      # Verifica se as datas de vencimento estão corretas
      12.times do |i|
        expected_date = subscription.send(:calculate_due_date, i + 1)
        expect(invoices[i].due_date).to eq(expected_date)
        expect(invoices[i].due_date.day).to eq([15, subscription.send(:days_in_month, expected_date)].min)
      end
    end
    
    it 'handles months with fewer days correctly' do
      # Cria uma assinatura no dia 31 para testar meses com menos dias
      feb_subscription = create(:subscription, client: client, plan: plan, subscription_date: Date.new(2025, 1, 31), start_date: Date.new(2025, 1, 31))
      feb_subscription.send(:create_booklet_with_invoices_and_accounts)
      
      # Verifica a fatura de fevereiro (que deve ter vencimento no dia 28/29)
      feb_invoice = feb_subscription.invoices.find_by(due_date: feb_subscription.send(:calculate_due_date, 1))
      expect(feb_invoice).to be_present
      expect(feb_invoice.due_date.month).to eq(2) # Fevereiro
      expect(feb_invoice.due_date.day).to eq(28) # Último dia de fevereiro em 2025
    end
    
    it 'creates invoices for package-based subscription without additional services' do
      package = create(:package, price: 80)
      subscription = create(:subscription, client: client, package: package, plan: nil, subscription_date: subscription_date, start_date: start_date)
      
      subscription.send(:create_booklet_with_invoices_and_accounts)
      
      # Verifica se o carnê foi criado com o valor correto
      expect(subscription.booklet).to be_present
      expect(subscription.booklet.amount).to eq(80 * 12) # Apenas o preço do pacote
      
      # Verifica se as faturas foram criadas
      expect(subscription.invoices.count).to eq(12)
      
      # Verifica se as contas foram criadas apenas para o pacote
      invoice = subscription.invoices.first
      expect(invoice.accounts.count).to eq(1) # Apenas uma para o pacote
      
      package_account = invoice.accounts.first
      expect(package_account.item_type).to eq('Package')
      expect(package_account.amount).to eq(80)
    end
  end
end
