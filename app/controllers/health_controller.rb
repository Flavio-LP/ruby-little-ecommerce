# Extends Rails' default /up health-check (which only verifies the app boots)
# to also verify the database and Redis connections (FR10).
class HealthController < ActionController::Base
  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping

    render plain: "OK", status: :ok
  rescue StandardError => e
    render plain: "Unhealthy: #{e.class}", status: :service_unavailable
  end
end
