class ProductsController < ApplicationController
  before_action :require_signed_in_user!
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.order(:name)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    result = CreateProduct.call(tenant: current_tenant, product_params: product_params)

    if result.success?
      redirect_to products_path, notice: "Product was successfully created."
    else
      @product = Product.new(product_params)
      flash.now[:alert] = result.message
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product was successfully destroyed."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :amount)
  end

  def current_tenant
    current_user&.tenant || ActsAsTenant.current_tenant
  end
end
