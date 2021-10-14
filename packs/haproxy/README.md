# HAProxy

This pack contains a single system job that runs HAProxy across all Nomad clients.

See the [Load Balancing with HAProxy](https://learn.hashicorp.com/tutorials/nomad/load-balancing-haproxy) tutorial for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `http_port` (number) - The Nomad client port that routes to the HAProxy. This port will be where you visit your loadbalanced application
- `ui_port` (number) - The port assigned to the HAProxy UI
- `service_name` (string) - The consul service you wish to load balance
- `consul_dns_port` (number) - The consul DNS port
- `version` (string) - The haproxy docker image version. For options, see: https://hub.docker.com/_/haproxy
- `pre_provisioned_slot_count` (number) - Backend slots to pre-provision in HAProxy config
- `resources` (object) - The resource to assign to the HAProxy system task that runs on every client
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed
