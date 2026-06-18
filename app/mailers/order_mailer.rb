# Preview/log-only in this MVP — no real SMTP provider configured.
class OrderMailer < ApplicationMailer
  def confirmation(order)
    @order = order
    mail(to: order.user&.email || "guest@example.com", subject: "Order confirmation ##{order.id}")
  end
end
