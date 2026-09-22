-- ============================================================
-- Table: users
-- Matches the User type used in the WSDL / OpenAPI definitions:
--   id       - unique identifier, assigned on creation
--   name     - required
--   role     - required
--   lastSeen - optional, set via the SetLastSeen operation
-- ============================================================

CREATE TABLE users (
    id        INT             PRIMARY KEY,
    name      VARCHAR(255)    NOT NULL,
    role      VARCHAR(100)    NOT NULL,
    last_seen TIMESTAMP WITH TIME ZONE       NULL,

    CONSTRAINT chk_users_name_not_blank CHECK (LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_users_role_not_blank CHECK (LENGTH(TRIM(role)) > 0)
);

-- Speeds up GetUsers lookups filtered by name and/or role
CREATE INDEX idx_users_name ON users (name);
CREATE INDEX idx_users_role ON users (role);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;