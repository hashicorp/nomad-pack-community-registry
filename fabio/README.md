# Fabio

This pack contains a single system job that runs Fabio across all Nomad clients.

Add a tag with `urlprefix-` to the `service` stanzas for Fabio-enabled Nomad services:

```
tags = ["urlprefix-/"]
```

See the [Load Balancing with Fabio](https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio) tutorial for more information.
