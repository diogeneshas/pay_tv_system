#!/usr/bin/env ruby
require_relative 'config/environment'

# Limpa o console
puts "\n" * 50
puts "=== TESTE DE FATURAMENTO AUTOMÁTICO ==="
puts "=" * 40

# Cria um cliente para teste
client = Client.find_or_create_by(name: "Cliente Teste", age: 30)
puts "Cliente criado: #{client.name} (ID: #{client.id})"

# Cria um plano para teste
plan = Plan.find_or_create_by(name: "Plano Teste", price: 50.0)
puts "Plano criado: #{plan.name} - R$ #{plan.price} (ID: #{plan.id})"

# Cria serviços adicionais para teste
service1 = AdditionalService.find_or_create_by(name: "Serviço Adicional 1", price: 10.0)
service2 = AdditionalService.find_or_create_by(name: "Serviço Adicional 2", price: 15.0)
puts "Serviços adicionais criados:"
puts "- #{service1.name} - R$ #{service1.price} (ID: #{service1.id})"
puts "- #{service2.name} - R$ #{service2.price} (ID: #{service2.id})"

# Cria um pacote para teste
package = Package.find_or_create_by(name: "Pacote Teste", plan: plan, additional_service: service1)
package.update(price: 60.0) if package.price.nil?
puts "Pacote criado: #{package.name} - R$ #{package.price} (ID: #{package.id})"

# Remove assinaturas anteriores do cliente para evitar duplicações
client.subscriptions.destroy_all if client.subscriptions.any?
puts "Assinaturas anteriores removidas."

puts "\n=== CRIANDO ASSINATURA COM PLANO ==="
# Cria uma assinatura com plano e serviços adicionais
subscription_date = Date.current
subscription = Subscription.new(
  client: client,
  plan: plan,
  package: nil,
  subscription_date: subscription_date,
  start_date: subscription_date,
  status: 'active'
)

# Adiciona serviços adicionais
subscription.additional_services << [service1, service2]

# Salva a assinatura (isso deve disparar o callback after_create :generate_billing)
if subscription.save
  puts "Assinatura com plano criada com sucesso! (ID: #{subscription.id})"
  puts "Data da assinatura: #{subscription.subscription_date}"
  puts "Valor total mensal: R$ #{subscription.total_amount}"
  
  # Verifica se o carnê foi criado
  booklet = subscription.booklet
  if booklet
    puts "\n=== CARNÊ GERADO ==="
    puts "ID: #{booklet.id}"
    puts "Valor total: R$ #{booklet.amount}"
    puts "Data de criação: #{booklet.created_at}"
    
    # Verifica se as faturas foram criadas
    invoices = subscription.invoices.order(:due_date)
    puts "\n=== FATURAS GERADAS (#{invoices.count}) ==="
    invoices.each_with_index do |invoice, index|
      puts "#{index + 1}. Vencimento: #{invoice.due_date.strftime('%d/%m/%Y')} - R$ #{invoice.amount}"
    end
    
    # Verifica se as contas foram criadas
    accounts = subscription.accounts.order(:due_date)
    puts "\n=== CONTAS GERADAS (#{accounts.count}) ==="
    accounts.group_by(&:due_date).each do |due_date, group|
      puts "Vencimento: #{due_date.strftime('%d/%m/%Y')}"
      group.each do |account|
        item_type = account.item_type == 'Plan' ? 'Plano' : 'Serviço Adicional'
        item_name = account.item.name
        puts "  - #{item_type}: #{item_name} - R$ #{account.amount}"
      end
    end
  else
    puts "ERRO: Carnê não foi gerado!"
  end
else
  puts "ERRO ao criar assinatura:"
  subscription.errors.full_messages.each do |message|
    puts "- #{message}"
  end
end

puts "\n=== CRIANDO ASSINATURA COM PACOTE ==="
# Cria uma assinatura com pacote (sem serviços adicionais)
subscription_date = Date.current
subscription_package = Subscription.new(
  client: client,
  plan: nil,
  package: package,
  subscription_date: subscription_date,
  start_date: subscription_date,
  status: 'active'
)

# Salva a assinatura (isso deve disparar o callback after_create :generate_billing)
if subscription_package.save
  puts "Assinatura com pacote criada com sucesso! (ID: #{subscription_package.id})"
  puts "Data da assinatura: #{subscription_package.subscription_date}"
  puts "Valor total mensal: R$ #{subscription_package.total_amount}"
  
  # Verifica se o carnê foi criado
  booklet = subscription_package.booklet
  if booklet
    puts "\n=== CARNÊ GERADO ==="
    puts "ID: #{booklet.id}"
    puts "Valor total: R$ #{booklet.amount}"
    puts "Data de criação: #{booklet.created_at}"
    
    # Verifica se as faturas foram criadas
    invoices = subscription_package.invoices.order(:due_date)
    puts "\n=== FATURAS GERADAS (#{invoices.count}) ==="
    invoices.each_with_index do |invoice, index|
      puts "#{index + 1}. Vencimento: #{invoice.due_date.strftime('%d/%m/%Y')} - R$ #{invoice.amount}"
    end
    
    # Verifica se as contas foram criadas
    accounts = subscription_package.accounts.order(:due_date)
    puts "\n=== CONTAS GERADAS (#{accounts.count}) ==="
    accounts.group_by(&:due_date).each do |due_date, group|
      puts "Vencimento: #{due_date.strftime('%d/%m/%Y')}"
      group.each do |account|
        item_type = account.item_type == 'Package' ? 'Pacote' : 'Serviço Adicional'
        item_name = account.item.name
        puts "  - #{item_type}: #{item_name} - R$ #{account.amount}"
      end
    end
  else
    puts "ERRO: Carnê não foi gerado!"
  end
else
  puts "ERRO ao criar assinatura:"
  subscription_package.errors.full_messages.each do |message|
    puts "- #{message}"
  end
end

puts "\n=== TESTE CONCLUÍDO ==="
