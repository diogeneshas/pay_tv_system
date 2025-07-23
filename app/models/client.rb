class Client < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :plans, through: :subscriptions
  has_many :packages, through: :subscriptions
  
  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 18 }
  
  def active_subscriptions
    subscriptions.where('subscription_date <= ?', Date.current)
  end
  
  def all_additional_services
    subscriptions.flat_map(&:additional_services).uniq
  end
  
  def total_subscription_amount
    subscriptions.sum(&:total_amount)
  end
end
