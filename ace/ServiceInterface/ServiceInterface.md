# ServiceInterface — Shared Library

## Purpose

**ServiceInterface** is an ACE *Shared Library* project. It holds the canonical WSDL and XML Schema definitions that describe the UserService contract. Both `UserServiceMapper` (REST API project) and `UserServiceProvider` (Application) declare a reference to this library so that every project uses the same validated message types.

## Files

| File | Description |
|------|-------------|
| `UserService.wsdl` | SOAP 1.1 service definition — operations, messages, binding, service endpoint |
| `UserService.xsd` | Root schema importing `UserService_InlineSchema1.xsd` |
| `UserService_InlineSchema1.xsd` | Type definitions — all request/response elements |
| `library.descriptor` | ACE shared library descriptor |

## WSDL Overview

- **Target namespace:** `http://example.com/userservice`
- **Binding style:** Document/Literal
- **Transport:** SOAP over HTTP (SOAP Action per operation)
- **Service endpoint:** `http://example.com/userservice`

### Port Type: `UserServicePortType`

| Operation | Pattern | SOAPAction |
|-----------|---------|------------|
| `CreateUser` | Request-Reply | `http://example.com/userservice/CreateUser` |
| `GetUsers` | Request-Reply | `http://example.com/userservice/GetUsers` |
| `SetLastSeen` | One-way (input only) | `http://example.com/userservice/SetLastSeen` |

## XML Schema

Defined in `UserService_InlineSchema1.xsd`, namespace `http://example.com/userservice`.

### Reusable Complex Type — `User`

| Field | Type | Required |
|-------|------|----------|
| `id` | `xsd:int` | Yes |
| `name` | `xsd:string` | Yes |
| `role` | `xsd:string` | Yes |
| `lastSeen` | `xsd:dateTime` | No (`minOccurs="0"`) |

### Document Elements

#### `CreateUserRequest`
| Field | Type | Required |
|-------|------|----------|
| `name` | `xsd:string` | Yes |
| `role` | `xsd:string` | Yes |

#### `CreateUserResponse`
| Field | Type | Required |
|-------|------|----------|
| `id` | `xsd:int` | Yes |

#### `GetUsersRequest`
All filters are optional; any combination may be supplied. If none are supplied, all users are returned.

| Field | Type | Required |
|-------|------|----------|
| `id` | `xsd:int` | No |
| `name` | `xsd:string` | No |
| `role` | `xsd:string` | No |

#### `GetUsersResponse`
| Field | Type | Multiplicity |
|-------|------|--------------|
| `user` | `tns:User` | 0..∞ |

#### `SetLastSeenRequest`
| Field | Type | Required |
|-------|------|----------|
| `id` | `xsd:int` | Yes |
| `lastSeen` | `xsd:dateTime` | Yes |

> **Note:** There is no `SetLastSeenResponse` — the operation is declared one-way in the WSDL.

## Dependencies

This library has no ACE project dependencies. It is consumed by:

- `UserServiceMapper` (via `restapi.descriptor` `sharedLibraryReference`)
- `UserServiceProvider` (via `application.descriptor` `sharedLibraryReference`)
