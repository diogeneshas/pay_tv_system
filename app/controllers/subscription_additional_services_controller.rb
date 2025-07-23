class SubscriptionAdditionalServicesController < ApplicationController
  before_action :set_subscription_additional_service, only: [:show, :edit, :update, :destroy]

  def index
    @subscription_additional_services = SubscriptionAdditionalService.all
  end

  def show
  end

  def new
    @subscription_additional_service = SubscriptionAdditionalService.new
  end

  def edit
  end

  def create
    @subscription_additional_service = SubscriptionAdditionalService.new(subscription_additional_service_params)

    if @subscription_additional_service.save
      redirect_to @subscription_additional_service, notice: 'Subscription additional service was successfully created.'
    else
      render :new
    end
  end

  def update
    if @subscription_additional_service.update(subscription_additional_service_params)
      redirect_to @subscription_additional_service, notice: 'Subscription additional service was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @subscription_additional_service.destroy
    redirect_to subscription_additional_services_path, notice: 'Subscription additional service was successfully destroyed.'
  end

  private

  def set_subscription_additional_service
    @subscription_additional_service = SubscriptionAdditionalService.find(params[:id])
  end

  def subscription_additional_service_params
    params.require(:subscription_additional_service).permit(:subscription_id, :additional_service_id, :notes)
  end
end
