class AdditionalServicesController < ApplicationController
  before_action :set_additional_service, only: %i[ show edit update destroy ]

  def index
    @additional_services = AdditionalService.all
  end 

  def show;end 

  def new
    @additional_service = AdditionalService.new
  end 

  def edit;end 

  def create
    @additional_service = AdditionalService.new(additional_service_params)

    if @additional_service.save
      redirect_to @additional_service, notice: "Additional service was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end 

  def update
    if @additional_service.update(additional_service_params)
      redirect_to @additional_service, notice: "Additional service was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end 

  def destroy
    @additional_service.destroy!

    redirect_to additional_services_path, status: :see_other, notice: "Additional service was successfully destroyed."
  end 

  private
    def set_additional_service
      @additional_service = AdditionalService.find(params.expect(:id))
    end

    def additional_service_params
      params.expect(additional_service: [ :name, :price ])
    end
end