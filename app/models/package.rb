
class Package < ApplicationRecord
  belongs_to :plan
  belongs_to :additional_service, optional: true

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  validates_presence_of :additional_service, unless: :price_present?

  before_validation :ensure_price_is_set

  def calculate_total_price
    return 0 unless plan&.price
    return 0 unless additional_service&.price
    
    plan.price + additional_service.price
  end

  private

  def price_present?
    price.present?
  end

  def ensure_price_is_set
    return if price.present?
    return unless additional_service.present?
    return unless plan&.price.present? && additional_service&.price.present?
    
    self.price = calculate_total_price
  end
end
