Rails.application.config.after_initialize do
  Rails.application.config.active_record_tenanted.tenant_resolver = ->(request) do
    # in production, we're using a two-level subdomain like "tenant.fizzy.37signals.com", but in
    # development and beta it's only a single-level subdomain.
    tld_length = request.domain == "37signals.com" ? 2 : 1
    request.subdomain(tld_length)
  end
end

ActiveSupport.on_load(:action_controller_base) do
  before_action { logger.struct tenant: ApplicationRecord.current_tenant }
end
