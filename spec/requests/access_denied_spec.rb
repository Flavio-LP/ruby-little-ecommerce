require "rails_helper"

# Smoke-tests the global CanCan::AccessDenied handling wired into
# ApplicationController (Story 1.4). Uses a throwaway controller/route
# since no real protected resource exists yet in Epic 1.
class AccessDeniedSmokeTestController < ApplicationController
  def show
    authorize! :manage, :all
  end
end

RSpec.describe "CanCan::AccessDenied handling", type: :request do
  before do
    Rails.application.routes.draw do
      get "/__access_denied_smoke_test", to: "access_denied_smoke_test#show"
    end
  end

  after do
    Rails.application.reload_routes!
  end

  it "redirects with an alert instead of raising a 500" do
    get "/__access_denied_smoke_test"

    expect(response).to have_http_status(:found)
    expect(flash[:alert]).to be_present
  end
end
