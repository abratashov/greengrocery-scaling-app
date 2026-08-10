class CreateProduct
  include Interactor

  def call
    product = Product.new(context.product_params.merge(tenant: context.tenant))

    if product.save
      context.product = product
    else
      context.fail!(message: product.errors.full_messages.join(", "))
    end
  end
end
