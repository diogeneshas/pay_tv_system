# Representa uma conta individual por cada item da assinatura
# @author Diogenes
# @since 1.0.0
class Account < ApplicationRecord
  belongs_to :subscription
  
  has_many :invoice_accounts, dependent: :destroy
  has_many :invoices, through: :invoice_accounts
  
  validates :item_type, presence: true
  validates :item_id, presence: true
  validates :due_date, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :item_id, uniqueness: { scope: [:subscription_id, :item_type, :due_date], message: 'já possui uma conta para este item nesta data' }
  
  # Retorna o item associado à conta (plano, pacote ou serviço adicional)
  # @return [Object] o item associado à conta
  def item
    item_type.constantize.find_by(id: item_id)
  end
  
  # Verifica se a conta está vencida
  # @return [Boolean] true se a conta estiver vencida, false caso contrário
  def overdue?
    due_date < Date.current
  end
end
