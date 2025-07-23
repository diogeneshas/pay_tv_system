# Representa uma assinatura de um cliente, vinculando-o a um plano ou pacote e serviços adicionais
# @author Diogenes
# @since 1.0.0
class Subscription < ApplicationRecord
  belongs_to :client
  belongs_to :plan, optional: true
  belongs_to :package, optional: true
  
  has_many :subscription_additional_services, dependent: :destroy
  has_many :additional_services, through: :subscription_additional_services
  
  has_many :accounts, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_one :booklet, dependent: :destroy
  
  validates :subscription_date, :start_date, presence: true
  validates :status, inclusion: { in: %w[active inactive] }, allow_nil: true
  validate :plan_or_package_present
  validate :plan_and_package_not_both_present
  validate :no_duplicate_additional_services
  validate :validate_additional_services_and_package
  
  after_create :generate_billing
  
  # Retorna o valor total da assinatura (plano/pacote + serviços adicionais)
  # @return [Numeric] o valor total da assinatura
  def total_amount
    total = 0
    
    # Adiciona o valor do plano ou pacote
    if plan.present?
      total += plan.price
    elsif package.present?
      total += package.price
    end
    
    # Adiciona o valor dos serviços adicionais (apenas se não for assinatura por pacote)
    if package.blank?
      additional_services.each do |service|
        total += service.price
      end
    end
    
    total
  end
  
  # Alias para total_amount para uso nas views
  # @return [Numeric] o valor total da assinatura
  def total_price
    total_amount
  end
  
  # Retorna um nome de exibição para a assinatura
  # @return [String] nome do cliente e pacote/plano
  def display_name
    client_name = client&.name || 'Cliente não especificado'
    package_name = package&.name || plan&.name || 'Sem plano/pacote'
    "#{client_name} - #{package_name}"
  end
  
  private
  
  # Garante que a assinatura tenha pelo menos um plano ou pacote
  def plan_or_package_present
    unless plan.present? || package.present?
      errors.add(:base, 'A assinatura deve ter pelo menos um plano ou pacote')
    end
  end
  
  # Garante que a assinatura não tenha plano e pacote ao mesmo tempo
  def plan_and_package_not_both_present
    if plan.present? && package.present?
      errors.add(:base, 'A assinatura não pode ter plano e pacote ao mesmo tempo')
    end
  end
  
  # Garante que não haja serviços adicionais duplicados
  def no_duplicate_additional_services
    service_ids = additional_services.map(&:id)
    if service_ids.uniq.length != service_ids.length
      errors.add(:additional_services, 'não podem ser duplicados')
    end
  end
  
  # Validação unificada para regras relacionadas a pacotes e serviços adicionais
  # 1. Se um pacote está selecionado, não deve haver serviços adicionais
  def validate_additional_services_and_package
    # Só aplicamos esta validação se um pacote estiver selecionado
    return unless package.present?
    
    # Se temos um pacote selecionado, não podemos ter serviços adicionais
    if additional_services.any?
      errors.add(:additional_services, 'não podem ser adicionados quando a assinatura é por pacote')
    end
  end
  
  # Retorna o valor base da assinatura (plano ou pacote)
  # @return [Decimal] o valor base da assinatura
  def base_amount
    if plan.present?
      plan.price
    elsif package.present?
      package.price
    else
      0
    end
  end
  
  # Retorna o valor total dos serviços adicionais
  # @return [Numeric] o valor total dos serviços adicionais
  def additional_services_amount
    additional_services.sum(&:price)
  end
  
  # Gera o faturamento para os próximos 12 meses
  def generate_billing
    create_booklet_with_invoices_and_accounts
  end
  
  # Cria o carnê com faturas e contas para os 12 meses seguintes à assinatura, começando pelo mês subsequente
  # @return [Booklet] o carnê criado
  def create_booklet_with_invoices_and_accounts
    # Calcula o valor total do carnê (12 meses)
    total_booklet_amount = total_amount * 12
    
    # Cria o carnê com o valor total
    booklet_record = create_booklet!(amount: total_booklet_amount, created_at: Time.current)
    
    # Gera faturas para os 12 meses seguintes à assinatura, começando pelo mês subsequente
    12.times do |i|
      # Calcula a data de vencimento (i+1 meses à frente)
      due_date = calculate_due_date(i + 1)
      
      # Cria a fatura para o mês
      invoice = invoices.create!(
        due_date: due_date, 
        amount: total_amount,
        created_at: Time.current
      )
      
      # Associa a fatura ao carnê
      booklet_record.invoices << invoice
      
      # Cria contas para cada item da assinatura
      create_accounts_for_invoice(invoice, due_date)
    end
    
    booklet_record
  end
  
  # Cria contas para cada item da assinatura e as associa à fatura
  # @param invoice [Invoice] a fatura à qual as contas serão associadas
  # @param due_date [Date] a data de vencimento das contas
  def create_accounts_for_invoice(invoice, due_date)
    current_time = Time.current
    
    # Conta para o plano ou pacote
    if plan.present?
      account = accounts.create!(
        item_type: 'Plan', 
        item_id: plan.id, 
        due_date: due_date, 
        amount: plan.price,
        created_at: current_time
      )
      invoice.accounts << account
    elsif package.present?
      account = accounts.create!(
        item_type: 'Package', 
        item_id: package.id, 
        due_date: due_date, 
        amount: package.price,
        created_at: current_time
      )
      invoice.accounts << account
    end
    
    # Contas para os serviços adicionais
    additional_services.each do |service|
      account = accounts.create!(
        item_type: 'AdditionalService', 
        item_id: service.id, 
        due_date: due_date, 
        amount: service.price,
        created_at: current_time
      )
      invoice.accounts << account
    end
  end
  
  # Calcula a data de vencimento para um mês específico
  # O dia de vencimento será sempre o mesmo dia da assinatura, respeitando o número de dias em cada mês
  # @param months_ahead [Integer] número de meses a partir da data de assinatura
  # @return [Date] a data de vencimento
  def calculate_due_date(months_ahead)
    # Obtém o mês alvo (months_ahead meses à frente)
    target_month = subscription_date.next_month(months_ahead)
    
    # Determina o dia de vencimento (mesmo dia da assinatura, ajustado para o número de dias no mês alvo)
    target_day = [subscription_date.day, days_in_month(target_month)].min
    
    # Retorna a data de vencimento
    Date.new(target_month.year, target_month.month, target_day)
  end
  
  # Retorna o número de dias em um determinado mês
  # @param date [Date] a data para a qual se deseja saber o número de dias no mês
  # @return [Integer] o número de dias no mês
  def days_in_month(date)
    Date.new(date.year, date.month, -1).day
  end
end
