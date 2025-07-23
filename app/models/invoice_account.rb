class InvoiceAccount < ApplicationRecord
  belongs_to :invoice
  belongs_to :account
  
  validates :invoice_id, uniqueness: { scope: :account_id, message: 'já possui esta conta associada' }
  validate :same_subscription
  validate :matching_due_dates
  
  private
  
  def same_subscription
    return unless invoice&.subscription_id && account&.subscription_id
    return if invoice.subscription_id == account.subscription_id
    
    errors.add(:base, 'A fatura e a conta devem pertencer à mesma assinatura')
  end
  
  def matching_due_dates
    return unless invoice&.due_date && account&.due_date
    return if invoice.due_date == account.due_date
    
    errors.add(:base, 'A fatura e a conta devem ter a mesma data de vencimento')
  end
end
