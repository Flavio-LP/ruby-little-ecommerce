ActsAsTenant.configure do |config|
  # Models declaring acts_as_tenant(:shop) raise instead of silently
  # returning unscoped data when no tenant is set — fail loudly, never leak.
  config.require_tenant = true
end
