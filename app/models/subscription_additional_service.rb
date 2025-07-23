class SubscriptionAdditionalService < ApplicationRecord
  belongs_to :subscription
  belongs_to :additional_service
  
  validates :subscription_id, uniqueness: { scope: :additional_service_id, message: 'já possui este serviço adicional' }
  validate :service_not_in_package
  
  private
  
  def service_not_in_package
    return unless subscription&.package&.additional_service_id == additional_service_id
    
    errors.add(:base, 'Este serviço adicional já está presente no pacote')
  end
end
