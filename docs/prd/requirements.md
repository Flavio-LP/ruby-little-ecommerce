# Requirements

## Functional

1. FR1: O sistema deve permitir que um vendedor se cadastre e, nesse processo, criar automaticamente sua própria loja (`Shop`) com um slug único usado no roteamento (`/:shop_slug/...`).
2. FR2: O sistema deve permitir que um vendedor autentique-se (login/logout) via Devise e acesse um painel administrativo restrito à sua própria loja.
3. FR3: O sistema deve permitir que um vendedor crie, edite, liste e desative produtos (nome, descrição, preço, SKU) dentro da sua própria loja.
4. FR4: O sistema deve impedir, em nível de dados, que um vendedor visualize ou modifique produtos/pedidos de outra loja (isolamento de tenant).
5. FR5: O sistema deve expor uma página pública de vitrine por loja (`/:shop_slug/produtos`) listando os produtos ativos daquela loja.
6. FR6: O sistema deve permitir que um cliente (autenticado ou visitante) adicione produtos a um carrinho de compras vinculado a uma loja específica.
7. FR7: O sistema deve permitir que o cliente atualize a quantidade ou remova itens do carrinho antes do checkout.
8. FR8: O sistema deve permitir que o cliente finalize o checkout, criando um pedido (`Order`) imutável com os itens, quantidades e preços vigentes no momento da compra.
9. FR9: O sistema deve permitir que o vendedor visualize, em seu painel, os pedidos recebidos em sua loja.
10. FR10: O sistema deve expor uma rota de health-check que retorna 200 quando a aplicação e suas dependências (banco, Redis) estão operacionais.
11. FR11: O sistema deve registrar/processar tarefas assíncronas (ex.: envio de e-mail de confirmação de pedido) via Sidekiq, sem bloquear a requisição HTTP do checkout.

## Non Functional

1. NFR1: Toda a persistência de dados deve ocorrer exclusivamente em PostgreSQL — nenhum dado de negócio deve viver apenas em cache/Redis.
2. NFR2: O ambiente de desenvolvimento completo (app, banco, Redis, worker) deve subir via `docker compose up` sem passos manuais adicionais.
3. NFR3: Toda lógica de negócio não-trivial (ex.: criação de pedido, registro de loja) deve ser implementada como objetos `Interactor`, mantendo controllers magros.
4. NFR4: Toda autorização de ações (quem pode fazer o quê) deve ser centralizada em classes CanCanCan `Ability`, nunca em condicionais espalhadas em controllers/views.
5. NFR5: Todo isolamento de dados entre tenants deve ser garantido estruturalmente via `acts_as_tenant` (escopo automático de query), não por filtros manuais espalhados pelo código.
6. NFR6: A suíte de testes (RSpec + Capybara) deve cobrir os fluxos críticos (cadastro de vendedor, CRUD de produto, carrinho, checkout) com testes de feature, além de testes unitários para Interactors e models.
7. NFR7: O pipeline de CI deve rodar `bundle exec rspec` e `bundle exec brakeman` em todo push/PR, bloqueando merge quando o Brakeman reportar findings de severidade alta/crítica.
8. NFR8: A interface deve ser server-rendered (HTML+ERB) com Bootstrap para estilo e Turbo para navegação sem reload completo; JavaScript customizado deve ser usado apenas onde Turbo/Stimulus não for suficiente.
