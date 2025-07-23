class BookletInvoice < ApplicationRecord
  belongs_to :booklet
  belongs_to :invoice
  
  validates :booklet_id, uniqueness: { scope: :invoice_id, message: 'já possui esta fatura associada' }
  validate :same_subscription
  
  private
  
  def same_subscription
    return unless booklet&.subscription_id && invoice&.subscription_id
    return if booklet.subscription_id == invoice.subscription_id
    
    errors.add(:base, 'O carnê e a fatura devem pertencer à mesma assinatura')
  end
end
