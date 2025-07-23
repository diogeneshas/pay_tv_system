class Booklet < ApplicationRecord
  belongs_to :subscription
  
  has_many :booklet_invoices, dependent: :destroy
  has_many :invoices, through: :booklet_invoices
  
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subscription_id, uniqueness: { message: 'já possui um carnê' }
  
  # Adiciona uma fatura ao carnê
  # @param invoice [Invoice] a fatura a ser adicionada
  def add_invoice(invoice)
    invoices << invoice unless invoices.include?(invoice)
  end
  
  # Retorna o número de faturas no carnê
  # @return [Integer] o número de faturas
  def invoice_count
    invoices.count
  end
  
  # Retorna as faturas ordenadas por data de vencimento
  # @return [Array<Invoice>] as faturas ordenadas
  def ordered_invoices
    invoices.order(:due_date)
  end
  
  # Verifica se o carnê está completo (12 faturas)
  # @return [Boolean] true se o carnê estiver completo, false caso contrário
  def complete?
    invoice_count == 12
  end
  
  # Calcula o valor total das faturas associadas ao carnê
  # @return [Numeric] o valor total das faturas
  def calculate_total
    invoices.sum(&:amount)
  end
end
