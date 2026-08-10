class CreateOrder
  include Interactor

  delegate :session, :tenant_name, :product_ids, :quantities, to: :context

  def call
    ActiveRecord::Base.transaction do
      user = User.find_by(id: session[:user_id])
      tenant = user&.tenant || Tenant.find_by!(name: tenant_name)

      order = Order.create!(
        user: user,
        tenant: tenant,
        state: "pending"
      )

      product_ids.to_a.each do |product_id|
        product = Product.find_by(id: product_id)
        next unless product && product.amount.positive?

        quantity = [quantities.fetch(product_id.to_s, 0).to_i, 1].max
        next if quantity <= 0

        total_price = product.price * quantity

        order.product_orders.create!(
          product: product,
          amount: quantity,
          total_price: total_price
        )

        product.update!(amount: product.amount - quantity)
      end

      order.create_payment!(
        total_price: order.product_orders.sum(&:total_price),
        state: "pending"
      )

      context.order = order
      context.user = user
      context.tenant = tenant
    end
  rescue ActiveRecord::RecordNotFound
    fail!(message: "Tenant not found")
  rescue ActiveRecord::RecordInvalid => e
    fail!(message: e.record.errors.full_messages.join(", "))
  end
end
