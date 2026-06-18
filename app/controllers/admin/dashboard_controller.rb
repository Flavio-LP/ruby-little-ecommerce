module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def show
      authorize! :manage, ActsAsTenant.current_tenant
    end
  end
end
