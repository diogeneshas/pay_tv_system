FactoryBot.define do
  factory :booklet_invoice do
    transient do
      shared_subscription { create(:subscription) }
    end
    
    # Cria o carnê associado à assinatura compartilhada
    booklet { association :booklet, subscription: shared_subscription }
    
    # Cria a fatura associada à mesma assinatura do carnê
    invoice { association :invoice, subscription: shared_subscription }
  end
end
