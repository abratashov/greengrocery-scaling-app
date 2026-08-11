# Greengrocery Scaling App

This is a Rails application that demonstrates horizontal scaling and database replication techniques.

### Scalability

Scalable application architecture includes:

1. Application layer
   - horizontal scaling
   - load balancing
   - stateless applications
   - API design

2. Database layer
   - indexes
   - query optimization
   - connection pooling
   - replication
   - partitioning
   - sharding

3. Performance
   - caching
   - CDN
   - background jobs
   - asynchronous processing

4. Infrastructure
   - Docker
   - orchestration / deployment
   - cloud infrastructure
   - monitoring
   - performance optimization
   - production troubleshooting

5. Architecture
   - service-oriented architecture
   - event-driven architecture
   - decoupling services

| Technique                          | What scales              | Main purpose                                | Tools / technologies                                  |
| ---------------------------------- | ------------------------ | ------------------------------------------- | ----------------------------------------------------- |
| **Horizontal application scaling** | Web/app instances        | More requests / higher availability         | Docker, Kamal, Kubernetes                             |
| **Load balancing**                 | Request distribution     | Distribute traffic across instances         | HAProxy, Nginx, Traefik, AWS ALB                      |
| **Vertical scaling**               | CPU/RAM of a server      | Handle more load on one instance            | VPS/cloud instance sizing, AWS EC2                    |
| **DB replication**                 | PostgreSQL read replicas | Scale **read throughput** / availability    | PostgreSQL streaming replication, Rails multiple DBs  |
| **DB sharding**                    | Data across multiple DBs | Scale **data size + writes**                | Rails multiple databases/sharding, PostgreSQL         |
| **DB partitioning**                | Large tables             | Performance / manageability                 | PostgreSQL declarative partitioning                   |
| **Caching**                        | Frequently accessed data | Reduce DB/app work                          | Redis, Solid Cache, Memcached, CDN                    |
| **Background jobs**                | Worker capacity          | Move expensive work out of web requests     | Solid Queue, Sidekiq, Resque                          |
| **CDN / edge caching**             | Static/cacheable content | Reduce origin traffic + latency             | Cloudflare, CloudFront, Fastly                        |
| **Connection pooling**             | DB connections           | Efficiently manage DB connections           | Rails connection pool, PgBouncer                      |
| **Asynchronous/event processing**  | Distributed workflows    | Decouple components / smooth traffic spikes | RabbitMQ, Kafka, Redis Streams, Solid Queue           |
| **Database optimization**          | Query workload           | Reduce DB execution time                    | PostgreSQL indexes, `EXPLAIN`, query optimization     |
| **Observability**                  | System visibility        | Detect bottlenecks / failures               | Sentry, New Relic, OpenTelemetry, Prometheus, Grafana |

### Initial Application

- Rails 8 + PostgreSQL

#### Business Logic

- Tenant
  - id
  - name
  - Support multitenancy with `acts_as_tenant`
  - Tenant identified by URL path:
    http://localhost:3000/{tenant_name}
  - Seed 2 tenants:
    - tenant1
    - tenant2

- User
  - tenant_id
  - email
  - password
  - Devise
  - Minimal email/password registration and authentication
  - User registers/signs in within the selected tenant
  - Seed:
    - user1@test.org / user1@test.org → tenant1
    - user2@test.org / user2@test.org → tenant2

- Product
  - tenant_id
  - name:string
  - price:decimal
  - amount:integer
  - amount >= 0
  - Products with amount == 0 are not displayed
  - Seed 100 fruits and vegetables

- Order
  - tenant_id
  - user_id
  - state:
    - new
    - in_progress
    - created
    - done
    - sent
    - delivered
    - cancelled
    - failed

- ProductOrder
  - order_id
  - product_id
  - amount:integer
  - amount > 0
  - total_price:decimal

- Payment
  - order_id
  - total_price:decimal
  - state:
    - pending
    - in_progress
    - paid
    - failed

#### Technical Requirements

- Rails CRUD
- Puma with multiple threads
- One PostgreSQL primary
- Kamal deployment
  - Separate PostgreSQL database for Solid Queue
  - Two Rails application instances
  - Two Solid Queue workers
  - Load balancing between Rails instances
  - Health-check endpoint
  - Environment/secrets management
  - Rolling deployment with minimal/no downtime

### Horizontal Scaling

Everything must run locally using Docker.

Demonstrate:

- Requests being distributed between Rails instance #1 and #2
- Both Rails instances sharing the same PostgreSQL data
- Background jobs processed by Solid Queue workers
- Multiple users/tenants working independently
- Tenant isolation

### DB Replication

After the initial application is working:

1. Add a PostgreSQL read replica.
2. Configure Rails to send read queries to the replica where appropriate.
3. Keep writes on the primary.
4. Demonstrate the read/write architecture.

### Out of scope: DB sharding

Then demonstrate tenant sharding:

1. Create a second PostgreSQL instance/database.
2. Move tenant1's data from the primary database to the second database.
3. Configure tenant → database routing.
4. Verify that tenant1 operates entirely from the second database.
5. Verify that tenant2 continues operating from the original database.
6. Verify that application behavior remains unchanged.

## Setup

```sh
mise ls-remote ruby | tail
mise ls-remote postgres | tail

mise use ruby@4.0.1
mise use postgres@18.4
# In case of errors run:
# sudo apt install -y flex bison build-essential libreadline-dev zlib1g-dev libssl-dev libicu-dev libxml2-dev libxslt1-dev liblz4-dev libzstd-dev

# To run in development or docker-compose mode comment / uncomment sections at:
# - app/models/application_record.rb
# - config/database.yml
# - config/environments/development.rb
# and follow instruction below.

# Then open in browser:
# http://localhost:3000
# user1@test.org / user1@test.org
```

### Develeopment mode running

```sh
bundle install
rails db:create
rails db:migrate
rails db:seed
rasils s
```

### Docker compose mode running

```sh
docker compose build
docker compose up
docker compose exec rails-1 bin/rails db:migrate db:seed
docker compose exec rails-1 bin/rails db:migrate:queue
docker compose run --rm rails-1 bin/rails db:migrate:queue
docker compose down
docker compose restart rails-1 rails-2 worker-1 worker-2
docker compose up --build
docker compose down

# Create replication
docker compose exec postgres psql -U postgres -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator_password';"
docker compose exec postgres psql -U postgres -c '\du'

docker compose run --rm --entrypoint bash postgres-replica
ls -la /var/lib/postgresql/data
rm -rf /var/lib/postgresql/data/*
PGPASSWORD=replicator_password pg_basebackup -h postgres -U replicator -D /var/lib/postgresql/data -Fp -Xs -P -R
test -f /var/lib/postgresql/data/standby.signal && echo "STANDBY OK"
exit

docker compose up -d postgres-replica
docker compose exec postgres-replica psql -U postgres -c "SELECT pg_is_in_recovery();"
docker compose exec postgres psql -U postgres -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"
docker compose exec postgres-replica psql -U postgres -d greengrocery_scaling_app_development -c '\dt'
docker volume ls | grep postgres
```

### Result

With Rails' `database_selector` configured with a 2-second delay, writes and reads immediately following a write are routed to the primary PostgreSQL instance. After the 2-second delay, subsequent reads can be routed to the PostgreSQL replica:

```sh
rails-1-1           | Started POST "/orders" for 172.24.0.6 at 2026-08-11 17:02:02 +0000
rails-1-1           | [DB-INFO] postgres:greengrocery_scaling_app_development
...
rails-2-1           | Started GET "/orders" for 172.24.0.6 at 2026-08-11 17:02:02 +0000
rails-2-1           | [DB-INFO] postgres:greengrocery_scaling_app_development
...
rails-1-1           | Started GET "/orders" for 172.24.0.6 at 2026-08-11 17:02:29 +0000
rails-1-1           | [DB-INFO] postgres-replica:greengrocery_scaling_app_development
```
