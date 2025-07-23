class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]

  def index
    @subscriptions = Subscription.all
  end

  def show
  end

  def new
    @subscription = Subscription.new
  end

  def edit
  end

  def create
    @subscription = Subscription.new(subscription_params)
    
    # Definir a data de assinatura como hoje se não estiver presente
    @subscription.subscription_date ||= Date.today

    if @subscription.save
      redirect_to @subscription, notice: 'Assinatura criada com sucesso.'
    else
      render :new
    end
  end

  def update
    # Garantir que os parâmetros de atualização não removam a data de assinatura
    update_params = subscription_params
    @subscription.subscription_date ||= Date.today
    
    if @subscription.update(update_params)
      redirect_to @subscription, notice: 'Assinatura atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @subscription.destroy
    redirect_to subscriptions_path, notice: 'Subscription was successfully destroyed.'
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:client_id, :plan_id, :package_id, :start_date, :end_date, :status, :notes, additional_service_ids: [])
  end
end
