# Boundary

Boundary is an intelligent proxy that creates granular, identity-based access controls for dynamic infrastructure. Boundary’s workflow layers security controls and integrations at multiple levels to monitor and manage user access through:

-  Tightly scoped identity-based permissions
- Just-in-time network and credential access for sessions via HashiCorp Vault
- Single sign-on to target services and applications via external identity providers
- Access-as-code to automate the configuration of user permissions
- Automated discovery of target systems
- Session monitoring and management for access created via Boundary.

[Source](https://www.boundaryproject.io/docs/what-is-boundary)

## Dependencies

This pack requires an existing, unused instance of Postgres DB to be running, and a credential for this instance to be supplied to Boundary.

The Boundary container itself, which will be scheduled by Nomad, must run on a Nomad client whose Docker driver has the IPC_LOCK capability allowed on the Nomad client. Alternatively, the Docker driver could instead be allowed to run privileged Docker containers.
