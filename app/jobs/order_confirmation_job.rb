class OrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    # .unscoped: this job runs outside any request, so there's no
    # ActsAsTenant.current_tenant set — we already have the specific id.
    order = Order.unscoped.find(order_id)
    OrderMailer.confirmation(order).deliver_now
  end
end
