Spree::Admin::OrdersController.class_eval do
  before_action :load_shipwire_order, only: [:shipwire]

  def shipwire
    order_to_shipwire

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def order_to_shipwire
    @shipwire_data = @order.in_shipwire
  rescue SolidusShipwire::ResponseException => e
    @error = e.response
  rescue RuntimeError => e
    @error = e.message
  end

  def load_shipwire_order
    load_order
  end
end
