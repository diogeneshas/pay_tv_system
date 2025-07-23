# Representa uma fatura que agrupa contas de um mês específico
# @author Diogenes
# @since 1.0.0
class Invoice < ApplicationRecord
  belongs_to :subscription
  
  has_many :invoice_accounts, dependent: :destroy
  has_many :accounts, through: :invoice_accounts
  
  has_many :booklet_invoices, dependent: :destroy
  has_many :booklets, through: :booklet_invoices
  
  validates :due_date, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subscription_id, uniqueness: { scope: :due_date, message: 'já possui uma fatura para esta data de vencimento' }
  
  # Verifica se a fatura está vencida
  # @return [Boolean] true se a fatura estiver vencida, false caso contrário
  def overdue?
    due_date < Date.current
  end
  
  # Adiciona uma conta à fatura
  # @param account [Account] a conta a ser adicionada
  def add_account(account)
    accounts << account unless accounts.include?(account)
  end
  
  # Retorna o mês e ano da fatura no formato "MM/AAAA"
  # @return [String] o mês e ano da fatura
  def month_year
    due_date.strftime('%m/%Y')
  end
  
  # Calcula o valor total das contas associadas à fatura
  # @return [Numeric] o valor total das contas
  def calculate_total
    accounts.sum(&:amount)
  end
end
