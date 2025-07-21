class PackagesController < ApplicationController
  before_action :set_package, only: %i[ show edit update destroy ]

  def index
    @packages = Package.all
  end

  def show;end

  def new
    @package = Package.new
  end

  def edit;end

  def create
    @package = Package.new(package_params)

    if @package.save
      redirect_to @package, notice: "Package was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @package.update(package_params)
      redirect_to @package, notice: "Package was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @package.destroy!

    redirect_to packages_path, status: :see_other, notice: "Package was successfully destroyed."
  end

  private
    def set_package
      @package = Package.find(params[:id])
    end

    def package_params
      params.require(:package).permit(:name, :price, :plan_id, :additional_service_id)
    end
end
