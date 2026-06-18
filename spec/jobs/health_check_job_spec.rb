require "rails_helper"

RSpec.describe HealthCheckJob, type: :job do
  include ActiveJob::TestHelper

  it "is enqueued on the default queue" do
    expect { HealthCheckJob.perform_later }
      .to have_enqueued_job(HealthCheckJob).on_queue("default")
  end

  it "executes without raising" do
    perform_enqueued_jobs do
      expect { HealthCheckJob.perform_later }.not_to raise_error
    end
  end
end
