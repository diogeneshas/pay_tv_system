FactoryBot.define do
  factory :invoice_account do
    # Cria uma assinatura compartilhada para garantir que invoice e account pertençam à mesma assinatura
    transient do
      shared_subscription { create(:subscription) }
      shared_due_date { Date.current }
    end
    
    # Cria a fatura associada à assinatura compartilhada
    invoice { association :invoice, subscription: shared_subscription, due_date: shared_due_date }
    
    # Cria a conta associada à mesma assinatura e com a mesma data de vencimento da fatura
    account { association :account, subscription: shared_subscription, due_date: shared_due_date }
  end
end
