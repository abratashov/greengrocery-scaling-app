class OrdersController < ApplicationController
  before_action :require_signed_in_user!
  before_action :set_order, only: %i[show]

  around_action :log_db_info

  def index
    @orders = Order.includes(:product_orders, :payment).order(created_at: :desc)
  end

  def show
  end

  def new
    @order = Order.new
    @products = Product.available.order(:name)
  end

  def create
    result = CreateOrder.call(
      session: session,
      tenant_name: ActsAsTenant.current_tenant&.name || params[:tenant_name],
      product_ids: params.dig(:order, :product_ids) || [],
      quantities: params.dig(:order, :quantities) || {}
    )

    if result.success?
      redirect_to orders_path, notice: "Order was successfully created."
    else
      @products = Product.available.order(:name)
      flash.now[:alert] = result.message
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
