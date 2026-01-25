# Rust SQLx Integration with Supabase Hybrid Workflow

This document provides comprehensive guidance for using SQLx with the hybrid ORM architecture pattern in Rust projects.

## Philosophy

**"SQLx for data modeling with compile-time safety, Supabase for data behavior"**

SQLx handles:
- Table definitions with compile-time SQL verification
- Migrations via `sqlx-cli`
- Type-safe queries checked against actual database
- Connection pooling

Supabase handles:
- Database functions (PL/pgSQL)
- Triggers
- Row Level Security (RLS) policies
- Extensions
- Auth integration

## File Structure

```
rust-service/
├── Cargo.toml
├── .env
├── .env.example
├── sqlx-data.json              # Offline query verification cache
├── migrations/                  # SQLx migrations (tables only)
│   ├── 20240301000001_create_products.sql
│   ├── 20240301000002_add_inventory.sql
│   └── ...
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── config.rs               # Environment configuration
│   ├── db/
│   │   ├── mod.rs
│   │   ├── pool.rs             # Database pool setup
│   │   ├── models/             # SQLx models (FromRow)
│   │   │   ├── mod.rs
│   │   │   ├── user.rs
│   │   │   ├── product.rs
│   │   │   └── order.rs
│   │   └── functions/          # Supabase DB function wrappers
│   │       ├── mod.rs
│   │       ├── orders.rs
│   │       └── analytics.rs
│   ├── api/
│   │   ├── mod.rs
│   │   ├── handlers/
│   │   ├── middleware/
│   │   │   └── auth.rs         # Supabase JWT verification
│   │   └── routes.rs
│   └── error.rs
└── scripts/
    └── sync-migrations.sh      # Copy to supabase/migrations/
```

## Dependencies

### Cargo.toml

```toml
[package]
name = "rust-service"
version = "0.1.0"
edition = "2021"

[dependencies]
# Async runtime
tokio = { version = "1.40", features = ["full"] }

# Database
sqlx = { version = "0.8", features = [
    "runtime-tokio",
    "tls-rustls",
    "postgres",
    "uuid",
    "chrono",
    "rust_decimal",
    "json"
]}

# Web framework (choose one)
axum = { version = "0.7", features = ["macros"] }
# OR: actix-web = "4"

# Serialization
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# JWT verification (Supabase auth)
jsonwebtoken = "9.3"
reqwest = { version = "0.12", features = ["json"] }

# Types
uuid = { version = "1.10", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
rust_decimal = { version = "1.36", features = ["serde"] }

# Configuration
dotenvy = "0.15"
config = "0.14"

# Error handling
thiserror = "1.0"
anyhow = "1.0"

# Logging
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

[dev-dependencies]
tokio-test = "0.4"
```

### Environment Configuration

```bash
# .env.example

# Database (use Supabase transaction pooler for connection pooling)
DATABASE_URL=postgres://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?sslmode=require

# Direct connection for migrations only
DATABASE_URL_DIRECT=postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres

# Supabase
SUPABASE_URL=https://[PROJECT].supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_JWT_SECRET=[JWT_SECRET]

# App
RUST_LOG=info
PORT=8080
```

## Database Configuration

### src/config.rs

```rust
use serde::Deserialize;

#[derive(Debug, Deserialize, Clone)]
pub struct Config {
    pub database_url: String,
    pub supabase_url: String,
    pub supabase_jwt_secret: String,
    pub port: u16,
}

impl Config {
    pub fn from_env() -> Result<Self, config::ConfigError> {
        dotenvy::dotenv().ok();

        config::Config::builder()
            .add_source(config::Environment::default())
            .build()?
            .try_deserialize()
    }
}
```

### src/db/pool.rs

```rust
use sqlx::postgres::{PgPool, PgPoolOptions};
use std::time::Duration;

pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(10)
        .min_connections(2)
        .acquire_timeout(Duration::from_secs(30))
        .idle_timeout(Duration::from_secs(600))
        .max_lifetime(Duration::from_secs(1800))
        .connect(database_url)
        .await
}

// For multi-tenant apps, set org_id in session
pub async fn set_tenant_context(
    pool: &PgPool,
    org_id: &uuid::Uuid,
) -> Result<(), sqlx::Error> {
    sqlx::query("SELECT set_config('app.current_org_id', $1, false)")
        .bind(org_id.to_string())
        .execute(pool)
        .await?;
    Ok(())
}
```

## Models with SQLx

### src/db/models/mod.rs

```rust
pub mod user;
pub mod product;
pub mod order;

pub use user::*;
pub use product::*;
pub use order::*;

use chrono::{DateTime, Utc};
use uuid::Uuid;

/// Common fields for multi-tenant tables
pub trait MultiTenant {
    fn org_id(&self) -> Uuid;
}

/// Common timestamp fields
pub trait Timestamped {
    fn created_at(&self) -> DateTime<Utc>;
    fn updated_at(&self) -> DateTime<Utc>;
}
```

### src/db/models/product.rs

```rust
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

use super::{MultiTenant, Timestamped};

/// Product model - maps to products table
#[derive(Debug, Clone, FromRow, Serialize, Deserialize)]
pub struct Product {
    pub id: Uuid,
    pub org_id: Uuid,
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub sku: Option<String>,
    pub active: bool,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl MultiTenant for Product {
    fn org_id(&self) -> Uuid {
        self.org_id
    }
}

impl Timestamped for Product {
    fn created_at(&self) -> DateTime<Utc> {
        self.created_at
    }
    fn updated_at(&self) -> DateTime<Utc> {
        self.updated_at
    }
}

/// Input for creating a new product
#[derive(Debug, Deserialize)]
pub struct CreateProduct {
    pub name: String,
    pub description: Option<String>,
    pub price: Decimal,
    pub sku: Option<String>,
}

/// Input for updating a product
#[derive(Debug, Deserialize)]
pub struct UpdateProduct {
    pub name: Option<String>,
    pub description: Option<String>,
    pub price: Option<Decimal>,
    pub sku: Option<String>,
    pub active: Option<bool>,
}

impl Product {
    /// Find product by ID (compile-time verified query)
    pub async fn find_by_id(
        pool: &sqlx::PgPool,
        id: Uuid,
    ) -> Result<Option<Self>, sqlx::Error> {
        sqlx::query_as!(
            Product,
            r#"
            SELECT id, org_id, name, description, price, sku, active, created_at, updated_at
            FROM products
            WHERE id = $1
            "#,
            id
        )
        .fetch_optional(pool)
        .await
    }

    /// Find all products for an organization
    pub async fn find_by_org(
        pool: &sqlx::PgPool,
        org_id: Uuid,
        limit: i64,
        offset: i64,
    ) -> Result<Vec<Self>, sqlx::Error> {
        sqlx::query_as!(
            Product,
            r#"
            SELECT id, org_id, name, description, price, sku, active, created_at, updated_at
            FROM products
            WHERE org_id = $1 AND active = true
            ORDER BY created_at DESC
            LIMIT $2 OFFSET $3
            "#,
            org_id,
            limit,
            offset
        )
        .fetch_all(pool)
        .await
    }

    /// Create a new product
    pub async fn create(
        pool: &sqlx::PgPool,
        org_id: Uuid,
        input: CreateProduct,
    ) -> Result<Self, sqlx::Error> {
        sqlx::query_as!(
            Product,
            r#"
            INSERT INTO products (org_id, name, description, price, sku)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id, org_id, name, description, price, sku, active, created_at, updated_at
            "#,
            org_id,
            input.name,
            input.description,
            input.price,
            input.sku
        )
        .fetch_one(pool)
        .await
    }

    /// Update a product
    pub async fn update(
        pool: &sqlx::PgPool,
        id: Uuid,
        input: UpdateProduct,
    ) -> Result<Self, sqlx::Error> {
        sqlx::query_as!(
            Product,
            r#"
            UPDATE products
            SET
                name = COALESCE($2, name),
                description = COALESCE($3, description),
                price = COALESCE($4, price),
                sku = COALESCE($5, sku),
                active = COALESCE($6, active),
                updated_at = NOW()
            WHERE id = $1
            RETURNING id, org_id, name, description, price, sku, active, created_at, updated_at
            "#,
            id,
            input.name,
            input.description,
            input.price,
            input.sku,
            input.active
        )
        .fetch_one(pool)
        .await
    }

    /// Soft delete a product
    pub async fn delete(pool: &sqlx::PgPool, id: Uuid) -> Result<(), sqlx::Error> {
        sqlx::query!(
            r#"
            UPDATE products SET active = false, updated_at = NOW()
            WHERE id = $1
            "#,
            id
        )
        .execute(pool)
        .await?;
        Ok(())
    }
}
```

### src/db/models/order.rs

```rust
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "order_status", rename_all = "snake_case")]
pub enum OrderStatus {
    Pending,
    Processing,
    Shipped,
    Delivered,
    Cancelled,
}

#[derive(Debug, Clone, FromRow, Serialize)]
pub struct Order {
    pub id: Uuid,
    pub org_id: Uuid,
    pub user_id: Uuid,
    pub status: OrderStatus,
    pub total_amount: Decimal,
    pub shipping_address: serde_json::Value,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, FromRow, Serialize)]
pub struct OrderItem {
    pub id: Uuid,
    pub order_id: Uuid,
    pub product_id: Uuid,
    pub quantity: i32,
    pub unit_price: Decimal,
}

/// Order with items - for API responses
#[derive(Debug, Serialize)]
pub struct OrderWithItems {
    #[serde(flatten)]
    pub order: Order,
    pub items: Vec<OrderItem>,
}

impl Order {
    /// Create order with items in a transaction
    pub async fn create_with_items(
        pool: &sqlx::PgPool,
        org_id: Uuid,
        user_id: Uuid,
        shipping_address: serde_json::Value,
        items: Vec<(Uuid, i32, Decimal)>, // (product_id, quantity, unit_price)
    ) -> Result<OrderWithItems, sqlx::Error> {
        let mut tx = pool.begin().await?;

        // Calculate total
        let total: Decimal = items.iter().map(|(_, qty, price)| price * Decimal::from(*qty)).sum();

        // Create order
        let order = sqlx::query_as!(
            Order,
            r#"
            INSERT INTO orders (org_id, user_id, status, total_amount, shipping_address)
            VALUES ($1, $2, 'pending', $3, $4)
            RETURNING id, org_id, user_id, status as "status: OrderStatus", total_amount, shipping_address, created_at, updated_at
            "#,
            org_id,
            user_id,
            total,
            shipping_address
        )
        .fetch_one(&mut *tx)
        .await?;

        // Create order items
        let mut order_items = Vec::with_capacity(items.len());
        for (product_id, quantity, unit_price) in items {
            let item = sqlx::query_as!(
                OrderItem,
                r#"
                INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                VALUES ($1, $2, $3, $4)
                RETURNING id, order_id, product_id, quantity, unit_price
                "#,
                order.id,
                product_id,
                quantity,
                unit_price
            )
            .fetch_one(&mut *tx)
            .await?;
            order_items.push(item);
        }

        tx.commit().await?;

        Ok(OrderWithItems {
            order,
            items: order_items,
        })
    }
}
```

## Migrations with sqlx-cli

### Installation

```bash
cargo install sqlx-cli --no-default-features --features postgres,rustls
```

### Creating Migrations

```bash
# Create a new migration
sqlx migrate add create_products

# This creates: migrations/<timestamp>_create_products.sql
```

### Migration Example

```sql
-- migrations/20240301000001_create_products.sql

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    sku VARCHAR(100),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_products_org_id ON products(org_id);
CREATE INDEX idx_products_sku ON products(sku) WHERE sku IS NOT NULL;
CREATE INDEX idx_products_active ON products(org_id, active) WHERE active = true;

-- Add comment for documentation
COMMENT ON TABLE products IS 'Product catalog for each organization';
```

### Running Migrations

```bash
# Run pending migrations
sqlx migrate run

# Check migration status
sqlx migrate info

# Revert last migration (if reversible)
sqlx migrate revert
```

### Offline Mode (Compile-time Verification)

SQLx verifies queries at compile time by connecting to your database. For CI/CD without database access:

```bash
# Generate sqlx-data.json from your local database
cargo sqlx prepare

# In CI, build with SQLX_OFFLINE=true
SQLX_OFFLINE=true cargo build --release
```

## Syncing to Supabase Migrations

### scripts/sync-migrations.sh

```bash
#!/bin/bash
# Sync SQLx migrations to supabase/migrations/ with proper numbering

set -e

SQLX_DIR="migrations"
SUPA_DIR="../supabase/migrations"
SERVICE_PREFIX="00300"  # Rust service uses 00300-00399 range

# Ensure supabase migrations directory exists
mkdir -p "$SUPA_DIR"

# Counter for migration ordering within our range
counter=0

for migration in "$SQLX_DIR"/*.sql; do
    if [ -f "$migration" ]; then
        filename=$(basename "$migration")
        # Extract the name part (after the timestamp)
        name_part=$(echo "$filename" | sed 's/^[0-9]*_//')

        # Create new filename with service prefix
        new_number=$(printf "%05d" $((${SERVICE_PREFIX#0} + counter)))
        new_filename="${new_number}_rust_${name_part}"

        # Copy if not already exists
        if [ ! -f "$SUPA_DIR/$new_filename" ]; then
            echo "Copying: $filename -> $new_filename"
            cp "$migration" "$SUPA_DIR/$new_filename"
        else
            echo "Skipping (exists): $new_filename"
        fi

        counter=$((counter + 1))
    fi
done

echo "Sync complete. Remember to create RLS policies separately."
```

## Database Function Wrappers

### src/db/functions/mod.rs

```rust
pub mod orders;
pub mod analytics;

pub use orders::*;
pub use analytics::*;
```

### src/db/functions/analytics.rs

```rust
use chrono::{DateTime, Utc};
use rust_decimal::Decimal;
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

/// Dashboard statistics from Supabase function
#[derive(Debug, Serialize)]
pub struct DashboardStats {
    pub total_orders: i64,
    pub total_revenue: Decimal,
    pub avg_order_value: Decimal,
    pub active_products: i64,
    pub period_start: DateTime<Utc>,
    pub period_end: DateTime<Utc>,
}

/// Call the get_dashboard_stats Supabase function
pub async fn get_dashboard_stats(
    pool: &PgPool,
    org_id: Uuid,
    start_date: DateTime<Utc>,
    end_date: DateTime<Utc>,
) -> Result<DashboardStats, sqlx::Error> {
    // Note: We use query_as with a raw query because SQLx can't verify
    // Supabase functions at compile time (they're PL/pgSQL)
    let row = sqlx::query_as::<_, (i64, Decimal, Decimal, i64, DateTime<Utc>, DateTime<Utc>)>(
        r#"
        SELECT
            (result).total_orders,
            (result).total_revenue,
            (result).avg_order_value,
            (result).active_products,
            (result).period_start,
            (result).period_end
        FROM get_dashboard_stats($1, $2, $3) AS result
        "#
    )
    .bind(org_id)
    .bind(start_date)
    .bind(end_date)
    .fetch_one(pool)
    .await?;

    Ok(DashboardStats {
        total_orders: row.0,
        total_revenue: row.1,
        avg_order_value: row.2,
        active_products: row.3,
        period_start: row.4,
        period_end: row.5,
    })
}

/// Top selling products for a period
#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct TopProduct {
    pub product_id: Uuid,
    pub product_name: String,
    pub total_sold: i64,
    pub total_revenue: Decimal,
}

pub async fn get_top_products(
    pool: &PgPool,
    org_id: Uuid,
    limit: i32,
) -> Result<Vec<TopProduct>, sqlx::Error> {
    sqlx::query_as::<_, TopProduct>(
        r#"
        SELECT * FROM get_top_products($1, $2)
        "#
    )
    .bind(org_id)
    .bind(limit)
    .fetch_all(pool)
    .await
}
```

### src/db/functions/orders.rs

```rust
use rust_decimal::Decimal;
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

/// Result of order total calculation from DB function
#[derive(Debug, Serialize)]
pub struct OrderTotalResult {
    pub subtotal: Decimal,
    pub tax: Decimal,
    pub shipping: Decimal,
    pub total: Decimal,
}

/// Calculate order totals using database function
/// This ensures consistent calculation logic across all services
pub async fn calculate_order_total(
    pool: &PgPool,
    order_id: Uuid,
) -> Result<OrderTotalResult, sqlx::Error> {
    let row = sqlx::query_as::<_, (Decimal, Decimal, Decimal, Decimal)>(
        "SELECT * FROM calculate_order_total($1)"
    )
    .bind(order_id)
    .fetch_one(pool)
    .await?;

    Ok(OrderTotalResult {
        subtotal: row.0,
        tax: row.1,
        shipping: row.2,
        total: row.3,
    })
}

/// Process order status change via database function
/// This handles all side effects (inventory, notifications) atomically
pub async fn process_order_status_change(
    pool: &PgPool,
    order_id: Uuid,
    new_status: &str,
    changed_by: Uuid,
) -> Result<bool, sqlx::Error> {
    let result = sqlx::query_scalar::<_, bool>(
        "SELECT process_order_status_change($1, $2::order_status, $3)"
    )
    .bind(order_id)
    .bind(new_status)
    .bind(changed_by)
    .fetch_one(pool)
    .await?;

    Ok(result)
}
```

## Supabase Auth Integration

### src/api/middleware/auth.rs

```rust
use axum::{
    extract::{FromRequestParts, State},
    http::{header::AUTHORIZATION, request::Parts, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::config::Config;

/// JWT claims from Supabase Auth
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SupabaseClaims {
    pub sub: Uuid,                    // User ID
    pub email: Option<String>,
    pub role: String,                 // "authenticated" or "anon"
    pub aud: String,                  // "authenticated"
    pub exp: i64,
    pub iat: i64,

    // Custom claims (set via auth hook or JWT template)
    pub org_id: Option<Uuid>,
    pub user_role: Option<String>,

    // App metadata
    pub app_metadata: Option<AppMetadata>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AppMetadata {
    pub provider: Option<String>,
    pub providers: Option<Vec<String>>,
}

/// Authenticated user extracted from JWT
#[derive(Debug, Clone)]
pub struct AuthenticatedUser {
    pub id: Uuid,
    pub email: Option<String>,
    pub org_id: Option<Uuid>,
    pub role: Option<String>,
}

#[derive(Debug)]
pub enum AuthError {
    MissingToken,
    InvalidToken(String),
    TokenExpired,
    MissingOrgId,
}

impl IntoResponse for AuthError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            AuthError::MissingToken => (StatusCode::UNAUTHORIZED, "Missing authorization token"),
            AuthError::InvalidToken(msg) => {
                tracing::warn!("Invalid token: {}", msg);
                (StatusCode::UNAUTHORIZED, "Invalid token")
            }
            AuthError::TokenExpired => (StatusCode::UNAUTHORIZED, "Token expired"),
            AuthError::MissingOrgId => (StatusCode::FORBIDDEN, "Organization ID required"),
        };

        (status, Json(serde_json::json!({ "error": message }))).into_response()
    }
}

/// Extract authenticated user from request
#[axum::async_trait]
impl<S> FromRequestParts<S> for AuthenticatedUser
where
    S: Send + Sync,
    Config: FromRequestParts<S>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        // Get config from state
        let config = parts
            .extensions
            .get::<Config>()
            .ok_or(AuthError::InvalidToken("Config not found".into()))?;

        // Extract Bearer token
        let auth_header = parts
            .headers
            .get(AUTHORIZATION)
            .and_then(|h| h.to_str().ok())
            .ok_or(AuthError::MissingToken)?;

        let token = auth_header
            .strip_prefix("Bearer ")
            .ok_or(AuthError::MissingToken)?;

        // Verify JWT
        let key = DecodingKey::from_secret(config.supabase_jwt_secret.as_bytes());
        let mut validation = Validation::new(Algorithm::HS256);
        validation.set_audience(&["authenticated"]);

        let token_data = decode::<SupabaseClaims>(token, &key, &validation)
            .map_err(|e| match e.kind() {
                jsonwebtoken::errors::ErrorKind::ExpiredSignature => AuthError::TokenExpired,
                _ => AuthError::InvalidToken(e.to_string()),
            })?;

        let claims = token_data.claims;

        Ok(AuthenticatedUser {
            id: claims.sub,
            email: claims.email,
            org_id: claims.org_id,
            role: claims.user_role,
        })
    }
}

/// Middleware to require org_id in JWT
pub struct RequireOrg(pub AuthenticatedUser);

#[axum::async_trait]
impl<S> FromRequestParts<S> for RequireOrg
where
    S: Send + Sync,
    AuthenticatedUser: FromRequestParts<S, Rejection = AuthError>,
{
    type Rejection = AuthError;

    async fn from_request_parts(parts: &mut Parts, state: &S) -> Result<Self, Self::Rejection> {
        let user = AuthenticatedUser::from_request_parts(parts, state).await?;

        if user.org_id.is_none() {
            return Err(AuthError::MissingOrgId);
        }

        Ok(RequireOrg(user))
    }
}
```

## API Integration (Axum)

### src/api/routes.rs

```rust
use axum::{
    extract::{Path, Query, State},
    routing::{get, post, put, delete},
    Json, Router,
};
use serde::Deserialize;
use uuid::Uuid;

use crate::{
    api::middleware::auth::{AuthenticatedUser, RequireOrg},
    db::models::{CreateProduct, Product, UpdateProduct},
    error::AppError,
};

#[derive(Clone)]
pub struct AppState {
    pub pool: sqlx::PgPool,
    pub config: crate::config::Config,
}

pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/products", get(list_products).post(create_product))
        .route("/products/:id", get(get_product).put(update_product).delete(delete_product))
        .route("/analytics/dashboard", get(get_dashboard))
        .with_state(state)
}

#[derive(Deserialize)]
pub struct PaginationParams {
    #[serde(default = "default_limit")]
    limit: i64,
    #[serde(default)]
    offset: i64,
}

fn default_limit() -> i64 { 20 }

async fn list_products(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Query(params): Query<PaginationParams>,
) -> Result<Json<Vec<Product>>, AppError> {
    let org_id = user.org_id.unwrap(); // Safe: RequireOrg ensures this exists

    let products = Product::find_by_org(&state.pool, org_id, params.limit, params.offset).await?;

    Ok(Json(products))
}

async fn get_product(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Path(id): Path<Uuid>,
) -> Result<Json<Product>, AppError> {
    let product = Product::find_by_id(&state.pool, id)
        .await?
        .ok_or(AppError::NotFound("Product not found".into()))?;

    // Verify ownership
    if product.org_id != user.org_id.unwrap() {
        return Err(AppError::Forbidden);
    }

    Ok(Json(product))
}

async fn create_product(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Json(input): Json<CreateProduct>,
) -> Result<Json<Product>, AppError> {
    let org_id = user.org_id.unwrap();

    let product = Product::create(&state.pool, org_id, input).await?;

    Ok(Json(product))
}

async fn update_product(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Path(id): Path<Uuid>,
    Json(input): Json<UpdateProduct>,
) -> Result<Json<Product>, AppError> {
    // Verify ownership first
    let existing = Product::find_by_id(&state.pool, id)
        .await?
        .ok_or(AppError::NotFound("Product not found".into()))?;

    if existing.org_id != user.org_id.unwrap() {
        return Err(AppError::Forbidden);
    }

    let product = Product::update(&state.pool, id, input).await?;

    Ok(Json(product))
}

async fn delete_product(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Path(id): Path<Uuid>,
) -> Result<(), AppError> {
    // Verify ownership first
    let existing = Product::find_by_id(&state.pool, id)
        .await?
        .ok_or(AppError::NotFound("Product not found".into()))?;

    if existing.org_id != user.org_id.unwrap() {
        return Err(AppError::Forbidden);
    }

    Product::delete(&state.pool, id).await?;

    Ok(())
}

async fn get_dashboard(
    State(state): State<AppState>,
    RequireOrg(user): RequireOrg,
    Query(params): Query<DashboardParams>,
) -> Result<Json<crate::db::functions::DashboardStats>, AppError> {
    let org_id = user.org_id.unwrap();

    let stats = crate::db::functions::get_dashboard_stats(
        &state.pool,
        org_id,
        params.start_date,
        params.end_date,
    ).await?;

    Ok(Json(stats))
}

#[derive(Deserialize)]
pub struct DashboardParams {
    start_date: chrono::DateTime<chrono::Utc>,
    end_date: chrono::DateTime<chrono::Utc>,
}
```

### src/error.rs

```rust
use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use serde_json::json;

#[derive(Debug)]
pub enum AppError {
    Database(sqlx::Error),
    NotFound(String),
    Forbidden,
    BadRequest(String),
    Internal(String),
}

impl From<sqlx::Error> for AppError {
    fn from(err: sqlx::Error) -> Self {
        tracing::error!("Database error: {:?}", err);
        AppError::Database(err)
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match self {
            AppError::Database(e) => {
                if let sqlx::Error::RowNotFound = e {
                    (StatusCode::NOT_FOUND, "Resource not found".to_string())
                } else {
                    (StatusCode::INTERNAL_SERVER_ERROR, "Database error".to_string())
                }
            }
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg),
            AppError::Forbidden => (StatusCode::FORBIDDEN, "Access denied".to_string()),
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg),
            AppError::Internal(msg) => (StatusCode::INTERNAL_SERVER_ERROR, msg),
        };

        (status, Json(json!({ "error": message }))).into_response()
    }
}
```

### src/main.rs

```rust
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod api;
mod config;
mod db;
mod error;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize logging
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::from_default_env())
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load configuration
    let config = config::Config::from_env()?;
    tracing::info!("Starting server on port {}", config.port);

    // Create database pool
    let pool = db::pool::create_pool(&config.database_url).await?;

    // Run pending migrations
    sqlx::migrate!("./migrations")
        .run(&pool)
        .await?;
    tracing::info!("Database migrations complete");

    // Build app state
    let state = api::routes::AppState {
        pool,
        config: config.clone(),
    };

    // Create router
    let app = api::routes::create_router(state);

    // Start server
    let listener = tokio::net::TcpListener::bind(format!("0.0.0.0:{}", config.port)).await?;
    tracing::info!("Server listening on {}", listener.local_addr()?);

    axum::serve(listener, app).await?;

    Ok(())
}
```

## Workflow Commands

### Development

```bash
# Start local Supabase
supabase start

# Run SQLx migrations
DATABASE_URL=postgres://postgres:postgres@localhost:54342/postgres sqlx migrate run

# Generate offline data for CI
cargo sqlx prepare

# Run the service
cargo run

# Watch mode (with cargo-watch)
cargo watch -x run
```

### Production Deployment

```bash
# Build release binary
SQLX_OFFLINE=true cargo build --release

# Run migrations via direct connection
DATABASE_URL=$DATABASE_URL_DIRECT sqlx migrate run

# Start service
./target/release/rust-service
```

## Key Differences from TypeScript/Python

| Aspect | TypeScript (Drizzle) | Python (SQLAlchemy) | Rust (SQLx) |
|--------|---------------------|---------------------|-------------|
| Query verification | Runtime | Runtime | **Compile-time** |
| Schema definition | TypeScript DSL | Python classes | Raw SQL |
| Migration format | SQL or TypeScript | Python (Alembic) | Raw SQL |
| Type generation | From schema | Runtime reflection | Macro expansion |
| Async support | Native | Optional (asyncio) | Native (tokio) |
| ORM abstraction | High | Very high | **Low (SQL-first)** |

## Best Practices

1. **Use `query_as!` for verified queries**: Compile-time checking catches SQL errors early
2. **Use `query_as` (no `!`) for DB functions**: Supabase functions can't be verified at compile time
3. **Generate `sqlx-data.json`**: Run `cargo sqlx prepare` before committing for CI/CD
4. **Use transactions for multi-table operations**: SQLx transactions work seamlessly
5. **Prefer direct connections for migrations**: Use `DATABASE_URL_DIRECT` with port 5432
6. **Use connection pooler for runtime**: Use transaction pooler (port 6543) for the application

## See Also

- [Hybrid ORM Architecture](./hybrid-orm-architecture.md) - Universal pattern overview
- [Database Functions](./database-functions.md) - PL/pgSQL patterns
- [Python SQLAlchemy Integration](./python-sqlalchemy-integration.md) - Python equivalent
- [Drizzle Integration](./drizzle-integration.md) - TypeScript equivalent
