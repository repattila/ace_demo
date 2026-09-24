# Database — Oracle Schema

## Purpose

The `db/` folder contains the Oracle SQL DDL script that creates the persistence layer used by the **UserServiceProvider** ACE application. The schema is intentionally minimal and maps one-to-one to the `User` type defined in the service contract.

## Files

| File | Description |
|------|-------------|
| `create_users_table.sql` | DDL — creates the `users` table, indexes, and sequence |

---

## Connection Details

| Property | Value (development) |
|----------|---------------------|
| Container | `DEV-OracleXE` (Docker network `acenet`) |
| Port | `1521` |
| Service | `xe` |
| ODBC DSN | `ORACLEDB` |
| ACE vault credential | `ORACLEDB` (username: `xe`, password: `pass123`) |

---

## Schema

### Table: `users`

```sql
CREATE TABLE users (
    id        INT             PRIMARY KEY,
    name      VARCHAR(255)    NOT NULL,
    role      VARCHAR(100)    NOT NULL,
    last_seen TIMESTAMP WITH TIME ZONE NULL,

    CONSTRAINT chk_users_name_not_blank CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_users_role_not_blank CHECK (LENGTH(TRIM(role)) > 0)
);
```

| Column | Type | Nullable | Constraints | Description |
|--------|------|----------|-------------|-------------|
| `id` | `INT` | No | `PRIMARY KEY` | Unique user identifier, assigned from sequence |
| `name` | `VARCHAR(255)` | No | `NOT NULL`, non-blank check | Display name |
| `role` | `VARCHAR(100)` | No | `NOT NULL`, non-blank check | User role |
| `last_seen` | `TIMESTAMP WITH TIME ZONE` | Yes | — | Last-seen timestamp, set via `SetLastSeen` operation |

### Indexes

| Index | Column(s) | Purpose |
|-------|-----------|---------|
| `idx_users_name` | `name` | Speeds up `GetUsers` queries filtered by name |
| `idx_users_role` | `role` | Speeds up `GetUsers` queries filtered by role |

### Sequence: `users_id_seq`

```sql
CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;
```

Used by the `CreateUser` ESQL module to generate unique IDs:

```esql
SET temp.Result[] = PASSTHRU('SELECT users_id_seq.NEXTVAL AS user_id FROM dual');
```

---

## Mapping to Service Contract

| Column | WSDL / OpenAPI field | Operations |
|--------|---------------------|------------|
| `id` | `User.id` / `id` | `CreateUser` (assigned), `GetUsers` (returned + filter), `SetLastSeen` (filter) |
| `name` | `User.name` / `name` | `CreateUser` (required input), `GetUsers` (returned + LIKE filter) |
| `role` | `User.role` / `role` | `CreateUser` (required input), `GetUsers` (returned + LIKE filter) |
| `last_seen` | `User.lastSeen` / `lastSeen` | `GetUsers` (returned, optional), `SetLastSeen` (updated) |

---

## ESQL ↔ SQL Operations

| ACE Operation | SQL | Notes |
|---------------|-----|-------|
| `CreateUser` | `SELECT users_id_seq.NEXTVAL FROM dual` + `INSERT INTO users (id, name, role)` | ID is generated before insert |
| `GetUsers` by ID | `SELECT * FROM USERS WHERE ID = ?` | Exact match |
| `GetUsers` by name/role | `SELECT * FROM USERS WHERE NAME LIKE ? AND ROLE LIKE ?` | Prefix search; missing filter defaults to `%` |
| `SetLastSeen` | `UPDATE USERS SET LAST_SEEN = ? WHERE ID = ?` | Timestamp cast to character with format `yyyy-MM-dd HH:mm:ss.SS ZZZ` |

---

## Notes

- The `last_seen` column is declared `TIMESTAMP WITH TIME ZONE` to preserve timezone information from the `xsd:dateTime` / `date-time` contract types.
- The ODBC connection in `odbc.ini` has `EnableTimestampwithTimezone` commented out. Uncomment this setting if Oracle `TIMESTAMP WITH TIMEZONE` columns are not handled correctly via ODBC.
- The `NO CYCLE` clause on the sequence means IDs will exhaust the Oracle `INT` range (2 147 483 647) in an extreme scenario. Consider `NUMBER` for production.
