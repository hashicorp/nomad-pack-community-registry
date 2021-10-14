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

See the [Load Balancing with Fabio](https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio) tutorial or the [Fabio Homepage](https://fabiolb.net/) for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

This pack has the following variables:

- `http_port` (number) - The Nomad client port that routes to the Fabio. This port will be where you visit your load balanced application
- `ui_port` (number) - The port assigned to visit the Fabio UI
- `resources` (object) - The resource to assign to the Fabio system task that runs on every client
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed
