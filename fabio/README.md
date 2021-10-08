# Fabio

This pack contains a single system job that runs [Fabio](https://fabiolb.net/) across all Nomad clients.

Add a tag with `urlprefix-/<PATH>` to the `service` stanzas for Fabio-enabled Nomad services. The following
tag would route fabio to the defined service if the url path started with "/myapp".

```
service {
  ...
  tags = ["urlprefix-/myapp"]
  ...
}
```

See the [Load Balancing with Fabio](https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio) tutorial for more information.
