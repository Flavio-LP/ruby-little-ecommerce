# Source Tree

> Fonte: `docs/architecture.md` — seção "Source Tree". Carregado sempre por `@dev` (`devLoadAlwaysFiles` em `core-config.yaml`).

```text
web_e_commerce/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb       # before_action :set_current_shop (TenantResolver)
│   │   ├── concerns/
│   │   │   └── tenant_resolvable.rb
│   │   ├── public/                         # vitrine pública (sem auth): products, cart, checkout
│   │   └── admin/                          # painel do vendedor (auth + role: seller)
│   ├── interactors/
│   │   ├── shops/register.rb
│   │   ├── cart/add_item.rb
│   │   └── checkout/create_order.rb
│   ├── jobs/
│   │   ├── order_confirmation_job.rb
│   │   └── health_check_job.rb
│   ├── models/
│   │   ├── ability.rb
│   │   ├── shop.rb
│   │   ├── user.rb
│   │   ├── product.rb
│   │   ├── cart.rb / cart_item.rb
│   │   └── order.rb / line_item.rb
│   └── views/
│       ├── public/...
│       └── admin/...
├── config/
│   ├── routes.rb            # scope ':shop_slug' do ... end
│   ├── sidekiq.yml
│   └── database.yml         # lê de ENV (docker-compose)
├── spec/
│   ├── models/
│   ├── requests/
│   ├── features/            # Capybara
│   └── interactors/
├── docker-compose.yml        # web, db, redis, worker
├── Dockerfile.dev             # build de desenvolvimento (distinto do Dockerfile de produção)
├── Dockerfile                 # já existente, produção (Kamal/Thruster) — não tocar
└── .github/workflows/ci.yml
```
