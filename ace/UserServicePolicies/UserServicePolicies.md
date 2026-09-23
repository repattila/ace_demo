# UserServicePolicies — Policy Project

## Purpose

**UserServicePolicies** is an ACE *Policy Project* that contains integration-server-level security and configuration policies. Policies are referenced by name from message flows or from the integration server configuration instead of being embedded in the flow artefacts.

## Files

| File | Description |
|------|-------------|
| `BasicAuth.policyxml` | Security profile policy — local Basic Authentication |
| `policy.descriptor` | ACE policy project descriptor |

---

## Policy: `BasicAuth`

**Policy template:** `SecurityProfiles`  
**Policy type:** `SecurityProfiles`

This policy defines a **Basic Authentication** security profile backed by a local credential alias stored in the ACE vault.

### Configuration

| Property | Value | Description |
|----------|-------|-------------|
| `authentication` | `Local` | Credentials are validated against the local ACE vault |
| `authenticationConfig` | `UserServiceAuthAlias` | Name of the vault credential alias used for validation |
| `mapping` | `NONE` | No identity mapping after authentication |
| `authorization` | `NONE` | No additional authorization check |
| `propagation` | `false` | Authenticated identity is not propagated downstream |
| `idToPropagateToTransport` | `Message ID` | (Not used when propagation is false) |
| `passwordValue` | `PLAIN` | Passwords are transmitted and stored in plain format within the vault |
| `rejectBlankpassword` | `false` | Blank passwords are accepted |

### Vault Credential Alias

The credential alias **`UserServiceAuthAlias`** is created at container build time by the following `mqsicredentials` command (see [`container`](container.md)):

```bash
mqsicredentials --work-dir /home/mqsi/ace-server \
  --create \
  --credential-type local \
  --credential-name UserServiceAuthAlias \
  --username test \
  --password test \
  --vault-key ${VAULT_KEY}
```

The demo uses `test/test` as the username/password pair. **Change these credentials before any non-development deployment.**

### How to Reference This Policy

Flows or nodes that require HTTP Basic Authentication reference this policy by its name `BasicAuth` within the `UserServicePolicies` project. The policy project must be deployed to the same integration server as the application.

---

## Security Considerations

| Concern | Current State | Recommendation |
|---------|--------------|----------------|
| Password storage | ACE vault (encrypted at rest with vault key) | Use a secrets manager or external vault in production |
| Vault key | Hardcoded in Dockerfile (`VAULT_KEY=passs1234`) | Inject at runtime via environment variable or secret |
| Credentials | `test/test` | Replace with strong credentials before production |
| Blank passwords | Allowed (`rejectBlankpassword=false`) | Set to `true` in production |
| TLS | Not configured (`https=false` in `restapi.descriptor`) | Enable HTTPS on the integration server for production |
