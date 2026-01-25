# Python SQLAlchemy + Alembic Integration with Supabase

## Overview

This guide covers integrating **SQLAlchemy** (ORM) with **Alembic** (migrations) in a hybrid Supabase setup for Python services.

**Key Components:**
- **SQLAlchemy**: ORM for data modeling and queries
- **Alembic**: Migration generation and management
- **asyncpg**: High-performance async PostgreSQL driver
- **Pydantic**: Data validation and serialization

## Recommended Python Stack

```
python-service/
├── app/
│   ├── __init__.py
│   ├── main.py                # FastAPI entry point
│   ├── config.py              # Environment configuration
│   ├── db/
│   │   ├── __init__.py
│   │   ├── base.py            # SQLAlchemy Base
│   │   ├── session.py         # Database connection/session
│   │   └── models/            # SQLAlchemy models
│   │       ├── __init__.py
│   │       ├── user.py
│   │       ├── product.py
│   │       └── order.py
│   ├── functions/             # Supabase DB function wrappers
│   │   ├── __init__.py
│   │   ├── dashboard.py
│   │   └── audit.py
│   ├── schemas/               # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── product.py
│   └── api/                   # API routes
│       └── ...
├── alembic/
│   ├── versions/              # Generated migrations
│   ├── env.py                 # Alembic environment
│   └── script.py.mako         # Migration template
├── alembic.ini
├── pyproject.toml             # or requirements.txt
└── .env
```

## Dependencies

```toml
# pyproject.toml (using uv/poetry)
[project]
dependencies = [
    "sqlalchemy[asyncio]>=2.0",
    "asyncpg>=0.29.0",
    "alembic>=1.13.0",
    "pydantic>=2.0",
    "pydantic-settings>=2.0",
    "python-dotenv>=1.0.0",
    "supabase>=2.0.0",  # Optional: for auth/storage
]
```

```bash
# Install with uv
uv pip install sqlalchemy[asyncio] asyncpg alembic pydantic pydantic-settings
```

## Configuration

### Environment Variables

```bash
# .env
DATABASE_URL=postgresql+asyncpg://postgres.PROJECT_REF:PASSWORD@aws-0-REGION.pooler.supabase.com:6543/postgres?pgbouncer=true
DATABASE_URL_DIRECT=postgresql://postgres:PASSWORD@db.PROJECT_REF.supabase.co:5432/postgres

# For Alembic (synchronous)
ALEMBIC_DATABASE_URL=postgresql://postgres:PASSWORD@db.PROJECT_REF.supabase.co:5432/postgres

# Supabase (optional, for auth/storage)
SUPABASE_URL=https://PROJECT_REF.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Settings Module

```python
# app/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    database_url: str
    database_url_direct: str
    supabase_url: str = ""
    supabase_key: str = ""
    supabase_service_role_key: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

@lru_cache()
def get_settings() -> Settings:
    return Settings()
```

## SQLAlchemy Setup

### Base Model

```python
# app/db/base.py
from sqlalchemy.orm import DeclarativeBase, declared_attr
from sqlalchemy import Column, DateTime
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import UUID
import uuid

class Base(DeclarativeBase):
    """Base class for all models"""

    @declared_attr.directive
    def __tablename__(cls) -> str:
        """Generate table name from class name (snake_case)"""
        import re
        name = cls.__name__
        return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()

class TimestampMixin:
    """Mixin for created_at and updated_at timestamps"""
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

class UUIDMixin:
    """Mixin for UUID primary key"""
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

class MultiTenantMixin:
    """Mixin for organization-based multi-tenancy"""
    org_id = Column(UUID(as_uuid=True), nullable=False, index=True)
```

### Database Session

```python
# app/db/session.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.pool import NullPool
from app.config import get_settings

settings = get_settings()

# Use NullPool for serverless/Supabase pooler compatibility
engine = create_async_engine(
    settings.database_url,
    poolclass=NullPool,  # Let Supabase handle pooling
    echo=False,
)

async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)

async def get_db() -> AsyncSession:
    """Dependency for FastAPI"""
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Model Examples

```python
# app/db/models/user.py
from sqlalchemy import Column, String, Boolean
from sqlalchemy.orm import relationship
from app.db.base import Base, UUIDMixin, TimestampMixin, MultiTenantMixin

class User(Base, UUIDMixin, TimestampMixin, MultiTenantMixin):
    """User model - structure only, RLS handled by Supabase"""

    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(255))
    is_active = Column(Boolean, default=True)

    # Relationships
    orders = relationship("Order", back_populates="user", lazy="selectin")

    def __repr__(self):
        return f"<User {self.email}>"
```

```python
# app/db/models/product.py
from sqlalchemy import Column, String, Numeric, Boolean, Text, Index
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base, UUIDMixin, TimestampMixin, MultiTenantMixin

class Product(Base, UUIDMixin, TimestampMixin, MultiTenantMixin):
    """Product model"""

    name = Column(String(255), nullable=False)
    description = Column(Text)
    price = Column(Numeric(10, 2), nullable=False)
    sku = Column(String(100), unique=True)
    is_active = Column(Boolean, default=True)

    __table_args__ = (
        Index('idx_products_org_active', 'org_id', 'is_active'),
        Index('idx_products_sku', 'sku'),
    )
```

```python
# app/db/models/order.py
from sqlalchemy import Column, String, Numeric, Integer, ForeignKey, Index, Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import enum
from app.db.base import Base, UUIDMixin, TimestampMixin, MultiTenantMixin

class OrderStatus(enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

class Order(Base, UUIDMixin, TimestampMixin, MultiTenantMixin):
    """Order model"""

    user_id = Column(UUID(as_uuid=True), ForeignKey("user.id"), nullable=False)
    status = Column(Enum(OrderStatus), default=OrderStatus.PENDING, nullable=False)
    total = Column(Numeric(12, 2), nullable=False, default=0)
    item_count = Column(Integer, default=0)

    # Relationships
    user = relationship("User", back_populates="orders")
    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan")

    __table_args__ = (
        Index('idx_orders_user', 'user_id'),
        Index('idx_orders_status', 'status'),
        Index('idx_orders_org_created', 'org_id', 'created_at'),
    )
```

### Model Registry

```python
# app/db/models/__init__.py
from app.db.base import Base
from app.db.models.user import User
from app.db.models.product import Product
from app.db.models.order import Order, OrderStatus

# Export all models for Alembic
__all__ = [
    "Base",
    "User",
    "Product",
    "Order",
    "OrderStatus",
]
```

## Alembic Configuration

### alembic.ini

```ini
# alembic.ini
[alembic]
script_location = alembic
prepend_sys_path = .
version_path_separator = os

# Use environment variable
sqlalchemy.url = driver://user:pass@localhost/dbname

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

### Alembic Environment

```python
# alembic/env.py
import asyncio
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import your models
from app.db.models import Base

# Alembic Config object
config = context.config

# Override sqlalchemy.url with environment variable
config.set_main_option("sqlalchemy.url", os.getenv("ALEMBIC_DATABASE_URL", ""))

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for autogenerate
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode - outputs SQL."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """Run migrations in 'online' mode."""
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

## Migration Workflow

### Generate Migration

```bash
# Autogenerate from model changes
alembic revision --autogenerate -m "add products table"

# Creates: alembic/versions/xxxx_add_products_table.py
```

### Review Generated Migration

```python
# alembic/versions/xxxx_add_products_table.py
"""add products table

Revision ID: xxxx
Revises: previous_revision
Create Date: 2024-01-15 10:00:00.000000
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = 'xxxx'
down_revision = 'previous_revision'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        'product',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('org_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('price', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('sku', sa.String(length=100), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('sku')
    )
    op.create_index('idx_products_org_active', 'product', ['org_id', 'is_active'], unique=False)
    op.create_index('idx_products_sku', 'product', ['sku'], unique=False)
    op.create_index(op.f('ix_product_org_id'), 'product', ['org_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_product_org_id'), table_name='product')
    op.drop_index('idx_products_sku', table_name='product')
    op.drop_index('idx_products_org_active', table_name='product')
    op.drop_table('product')
```

### Export SQL for Supabase

```bash
# Generate SQL from migration (offline mode)
alembic upgrade head --sql > /tmp/alembic_products.sql

# Or manually copy the upgrade() SQL
# Then copy to Supabase:
cp /tmp/alembic_products.sql ../supabase/migrations/00200_alembic_products.sql
```

## Calling Supabase Database Functions

### Function Wrapper Pattern

```python
# app/functions/dashboard.py
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from typing import TypedDict
from decimal import Decimal
from uuid import UUID


class DashboardStats(TypedDict):
    total_orders: int
    total_revenue: Decimal
    avg_order_value: Decimal
    orders_this_month: int


async def get_dashboard_stats(db: AsyncSession, org_id: UUID) -> DashboardStats:
    """
    Call Supabase database function: get_dashboard_stats(p_org_id UUID)

    The function is defined in supabase/migrations/00002_core_functions.sql
    """
    result = await db.execute(
        text("SELECT * FROM get_dashboard_stats(:org_id::uuid)"),
        {"org_id": str(org_id)}
    )
    row = result.fetchone()

    if row is None:
        return {
            "total_orders": 0,
            "total_revenue": Decimal("0"),
            "avg_order_value": Decimal("0"),
            "orders_this_month": 0,
        }

    return {
        "total_orders": row.total_orders or 0,
        "total_revenue": Decimal(str(row.total_revenue or 0)),
        "avg_order_value": Decimal(str(row.avg_order_value or 0)),
        "orders_this_month": row.orders_this_month or 0,
    }
```

```python
# app/functions/audit.py
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel


class AuditEntry(BaseModel):
    id: int
    user_id: Optional[UUID]
    action: str
    table_name: str
    record_id: UUID
    old_data: Optional[dict]
    new_data: Optional[dict]
    timestamp: datetime

    class Config:
        from_attributes = True


async def get_audit_history(
    db: AsyncSession,
    table_name: str,
    record_id: UUID,
    limit: int = 50
) -> list[AuditEntry]:
    """
    Get audit history for a specific record.
    Uses the audit_log table populated by triggers.
    """
    result = await db.execute(
        text("""
            SELECT id, user_id, action, table_name, record_id,
                   old_data::json as old_data, new_data::json as new_data,
                   timestamp
            FROM public.audit_log
            WHERE table_name = :table_name AND record_id = :record_id::uuid
            ORDER BY timestamp DESC
            LIMIT :limit
        """),
        {"table_name": table_name, "record_id": str(record_id), "limit": limit}
    )

    return [AuditEntry.model_validate(row._mapping) for row in result.fetchall()]
```

### Transaction with Function Calls

```python
# app/functions/orders.py
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from decimal import Decimal


async def calculate_order_total(db: AsyncSession, order_id: UUID) -> Decimal:
    """
    Call database function to calculate order total with tax.

    Defined in supabase/migrations/00201_order_functions.sql:
    CREATE FUNCTION calculate_order_total(p_order_id UUID) RETURNS NUMERIC
    """
    result = await db.execute(
        text("SELECT calculate_order_total(:order_id::uuid) as total"),
        {"order_id": str(order_id)}
    )
    row = result.fetchone()
    return Decimal(str(row.total)) if row else Decimal("0")


async def process_order(db: AsyncSession, order_id: UUID) -> dict:
    """
    Process order using database transaction with function calls.
    """
    async with db.begin():
        # Calculate total (database function)
        total = await calculate_order_total(db, order_id)

        # Update order status (ORM)
        await db.execute(
            text("""
                UPDATE "order"
                SET status = 'processing', total = :total, updated_at = NOW()
                WHERE id = :order_id::uuid
            """),
            {"order_id": str(order_id), "total": total}
        )

        # Trigger inventory update (database function)
        await db.execute(
            text("SELECT update_inventory_for_order(:order_id::uuid)"),
            {"order_id": str(order_id)}
        )

        return {"order_id": str(order_id), "total": total, "status": "processing"}
```

## Pydantic Schemas

```python
# app/schemas/product.py
from pydantic import BaseModel, ConfigDict
from uuid import UUID
from decimal import Decimal
from datetime import datetime
from typing import Optional


class ProductBase(BaseModel):
    """Base schema for Product"""
    name: str
    description: Optional[str] = None
    price: Decimal
    sku: Optional[str] = None
    is_active: bool = True


class ProductCreate(ProductBase):
    """Schema for creating a product"""
    org_id: UUID


class ProductUpdate(BaseModel):
    """Schema for updating a product (all fields optional)"""
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[Decimal] = None
    sku: Optional[str] = None
    is_active: Optional[bool] = None


class ProductResponse(ProductBase):
    """Schema for product responses"""
    id: UUID
    org_id: UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ProductListResponse(BaseModel):
    """Schema for paginated product list"""
    items: list[ProductResponse]
    total: int
    page: int
    page_size: int
```

## Query Patterns

### Basic CRUD with SQLAlchemy

```python
# app/db/queries/products.py
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import Optional
from app.db.models import Product
from app.schemas.product import ProductCreate, ProductUpdate


async def get_product(db: AsyncSession, product_id: UUID) -> Optional[Product]:
    """Get a single product by ID"""
    result = await db.execute(
        select(Product).where(Product.id == product_id)
    )
    return result.scalar_one_or_none()


async def get_products(
    db: AsyncSession,
    org_id: UUID,
    skip: int = 0,
    limit: int = 100,
    active_only: bool = True
) -> tuple[list[Product], int]:
    """Get paginated products for an organization"""
    query = select(Product).where(Product.org_id == org_id)

    if active_only:
        query = query.where(Product.is_active == True)

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total = (await db.execute(count_query)).scalar() or 0

    # Get paginated results
    query = query.offset(skip).limit(limit).order_by(Product.created_at.desc())
    result = await db.execute(query)

    return list(result.scalars().all()), total


async def create_product(db: AsyncSession, product: ProductCreate) -> Product:
    """Create a new product"""
    db_product = Product(**product.model_dump())
    db.add(db_product)
    await db.flush()
    await db.refresh(db_product)
    return db_product


async def update_product(
    db: AsyncSession,
    product_id: UUID,
    product: ProductUpdate
) -> Optional[Product]:
    """Update a product"""
    db_product = await get_product(db, product_id)
    if db_product is None:
        return None

    update_data = product.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_product, field, value)

    await db.flush()
    await db.refresh(db_product)
    return db_product


async def delete_product(db: AsyncSession, product_id: UUID) -> bool:
    """Soft delete a product (set is_active = False)"""
    db_product = await get_product(db, product_id)
    if db_product is None:
        return False

    db_product.is_active = False
    await db.flush()
    return True
```

### Complex Queries with Raw SQL

```python
# app/db/queries/analytics.py
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from datetime import datetime, timedelta
from typing import TypedDict


class SalesAnalytics(TypedDict):
    date: str
    orders_count: int
    revenue: float
    avg_order_value: float


async def get_sales_analytics(
    db: AsyncSession,
    org_id: UUID,
    days: int = 30
) -> list[SalesAnalytics]:
    """
    Get daily sales analytics using a complex SQL query.
    This is more efficient than doing it in Python.
    """
    result = await db.execute(
        text("""
            SELECT
                DATE(created_at) as date,
                COUNT(*) as orders_count,
                SUM(total)::float as revenue,
                AVG(total)::float as avg_order_value
            FROM "order"
            WHERE org_id = :org_id::uuid
              AND created_at >= :start_date
              AND status != 'cancelled'
            GROUP BY DATE(created_at)
            ORDER BY date DESC
        """),
        {
            "org_id": str(org_id),
            "start_date": datetime.utcnow() - timedelta(days=days)
        }
    )

    return [
        {
            "date": str(row.date),
            "orders_count": row.orders_count,
            "revenue": row.revenue or 0,
            "avg_order_value": row.avg_order_value or 0,
        }
        for row in result.fetchall()
    ]
```

## FastAPI Integration

```python
# app/api/products.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from app.db.session import get_db
from app.db.queries import products as product_queries
from app.schemas.product import (
    ProductCreate,
    ProductUpdate,
    ProductResponse,
    ProductListResponse,
)

router = APIRouter(prefix="/products", tags=["products"])


@router.get("", response_model=ProductListResponse)
async def list_products(
    org_id: UUID,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    active_only: bool = True,
    db: AsyncSession = Depends(get_db),
):
    """List products for an organization"""
    skip = (page - 1) * page_size
    items, total = await product_queries.get_products(
        db, org_id, skip=skip, limit=page_size, active_only=active_only
    )
    return ProductListResponse(
        items=[ProductResponse.model_validate(p) for p in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post("", response_model=ProductResponse, status_code=201)
async def create_product(
    product: ProductCreate,
    db: AsyncSession = Depends(get_db),
):
    """Create a new product"""
    db_product = await product_queries.create_product(db, product)
    return ProductResponse.model_validate(db_product)


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get a product by ID"""
    product = await product_queries.get_product(db, product_id)
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return ProductResponse.model_validate(product)


@router.patch("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: UUID,
    product: ProductUpdate,
    db: AsyncSession = Depends(get_db),
):
    """Update a product"""
    db_product = await product_queries.update_product(db, product_id, product)
    if db_product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return ProductResponse.model_validate(db_product)


@router.delete("/{product_id}", status_code=204)
async def delete_product(
    product_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Soft delete a product"""
    success = await product_queries.delete_product(db, product_id)
    if not success:
        raise HTTPException(status_code=404, detail="Product not found")
```

## Supabase Auth Integration

```python
# app/auth/supabase.py
from supabase import create_client, Client
from fastapi import Request, HTTPException, Depends
from typing import Optional
from uuid import UUID
from app.config import get_settings
from pydantic import BaseModel


class AuthUser(BaseModel):
    id: UUID
    email: str
    org_id: Optional[UUID] = None
    role: str = "user"


settings = get_settings()
supabase: Client = create_client(settings.supabase_url, settings.supabase_key)


async def get_current_user(request: Request) -> AuthUser:
    """
    Extract and verify Supabase JWT from Authorization header.
    """
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing authorization header")

    token = auth_header.replace("Bearer ", "")

    try:
        # Verify with Supabase
        response = supabase.auth.get_user(token)
        if response.user is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        user = response.user

        # Extract org_id from JWT claims (custom claim)
        org_id = user.user_metadata.get("org_id") if user.user_metadata else None

        return AuthUser(
            id=UUID(user.id),
            email=user.email or "",
            org_id=UUID(org_id) if org_id else None,
            role=user.role or "user",
        )
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))
```

## Summary

| Aspect | Tool/Approach |
|--------|--------------|
| ORM | SQLAlchemy 2.0+ with async |
| Migrations | Alembic with autogenerate |
| Driver | asyncpg (high-performance) |
| Validation | Pydantic v2 |
| API | FastAPI |
| Auth | Supabase Auth with JWT |
| Type Safety | Pydantic + SQLAlchemy type hints |

**Hybrid Workflow:**
1. Define models in `app/db/models/`
2. Generate migration: `alembic revision --autogenerate -m "description"`
3. Review and export SQL to `supabase/migrations/`
4. Add RLS/triggers/functions in separate Supabase migrations
5. Apply: `supabase db reset`
