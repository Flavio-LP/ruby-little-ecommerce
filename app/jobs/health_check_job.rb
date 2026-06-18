# Trivial smoke-test job verifying the Sidekiq/Redis wiring actually works
# end-to-end (Story 1.5). Not used by application logic.
class HealthCheckJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("[HealthCheckJob] executed at #{Time.current}")
  end
end
