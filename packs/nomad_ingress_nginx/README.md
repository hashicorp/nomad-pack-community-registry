# Nomad Ingress Nginx

This pack deploys a Nginx reverse proxy that is automatically configured to
handle traffic ingress to allocations based on service meta values and tags.

Jobs can register themselves in the ingress by annotating their services either
using `tags` or `meta` values.

```hcl
service {
  name = "webapp"
  port = "http"

  tags = [
    "nomad_ingress_enabled=true",
    "nomad_ingress_hostname=webapp.example.com",
  ]
}
```

```hcl
service {
  name = "webapp"
  port = "http"

  meta {
    nomad_ingress_enabled  = true
    nomad_ingress_hostname = "webapp.example.com"
  }
}
```

## Dependencies

This pack requires a client with Docker installed and a working Consul cluster.

## Getting started

Start a local Nomad and Consul agent. If you are not on Linux, refer to this
[FAQ entry][nomad_docs_faq] so your containers can communicate properly.

The Nginx ingress can use hostnames to route requests to the appropriate
allocations. When testing locally, you can add entries to your `/etc/hosts` file
to simulate entries in a DNS.

In this example, you will use the [`fake-service`] sample app, so add an entry
like this to your `/etc/hosts` file:

```
<YOUR_IP> fake.example.com
```

If you are on Linux you can set `<YOUR_IP>` to `127.0.0.1`, otherwise use the IP
address defined in your Consul agent `-bind` configuration from the previous
step.

When you access `fake.example.com` your system will resolve this hostname to
your own IP address.

Run the Nginx ingress pack:

```shell-session
$ nomad-pack run nomad_ingress_nginx
```

Next, copy this sample `fake-service` job into a file called
`fake-service.nomad` and run it:

```hcl
job "fake-service" {
  datacenters = ["dc1"]

  group "fake-service" {
    count = 3

    network {
      port "http" {}
    }

    service {
      name = "fake-service"
      port = "http"
    }

    task "fake-service" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.22.7"
        ports = ["http"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
      }
    }
  }
}
```

```shell-session
$ nomad run fake-service.nomad
```

Without an ingress it's hard to access this application, since each allocation
will have its own IP and port. That's where the ingress comes handy.

#### Hostname ingress

Update the `fake-service` job to add some `meta` values to the service and run
the job again:

```diff
job "fake_service" {
  # ...
  group "fake-service" {
    # ...
    service {
      name = "fake-service"
      port = "http"

+     meta {
+       nomad_ingress_enabled  = true
+       nomad_ingress_hostname = "fake.example.com"
+     }
    }
    # ...
  }
}
```

```shell-session
$ nomad run fake-service.nomad
```

Open your browser and navigate to http://fake.example.com and verify that your
app is reachable.

#### Path ingress

You can also route traffic using a specifc URL path. Update the service of
`fake-service` like this:

```diff
job "fake_service" {
  # ...
  group "fake-service" {
    # ...
    service {
      name = "fake-service"
      port = "http"

      meta {
        nomad_ingress_enabled  = true
-       nomad_ingress_hostname = "fake.example.com"
+       nomad_ingress_path     = "/fake"
      }
    }
    # ...
  }
}
```

Open your browser and navigate to `http://<YOUR_IP>/fake` and verify that your
app is reachable using a path now.

#### Port ingress

Another option is to access services using different ports. This requires
reconfiguring the `nomad_ingress_nginx` pack instance deployed earlier to
include additional ports:

```shell-session
$ nomad-pack run -var 'nginx_extra_ports=[{name: "fake-service", port: 8080, host_network: ""}]' nomad_ingress_nginx
```

Update the `fake-service` job so that it uses the new port:

```diff
job "fake_service" {
  # ...
  group "fake-service" {
    # ...
    service {
      name = "fake-service"
      port = "http"

      meta {
        nomad_ingress_enabled = true
-       nomad_ingress_path    = "/fake"
+       nomad_ingress_port    = "8080"
      }
    }
    # ...
  }
}
```

Open your browser and navigate to `http://<YOUR_IP>:8080` and verify that your
app is reachable using the new port.

## Variables

- `datacenters` `(list(string): ["dc1"])` - A list of datacenters in the region
  which are eligible for task placement.
- `job_name` `(string: "")` - The name to use as the job name. Defaults to the
  pack name.
- `job_type` `(string: "system")` - The scheduler type to use for the job.
- `namespace` `(string: "default")` - The namespace where the job will be
  placed
- `region` `(string: "global")` - The region where the job will be placed.
- `http_port` `(number: 80)` - The Nomad client port that routes to the Nginx
  ingress.
- `http_port_host_network` `(string: "")` - The Nomad client host network where
  the `http_port` will be allocated.
- `nginx_count` `(number: 1)` - The number of instances of the Nginx ingress to
  run. Only used if `job_type` is `service`
- `nginx_extra_ports` `(list(Port): [])` - List of additional ports to
  assign to the Nginx ingress.
- `nginx_image` `(string: "nginx:1.21")` - The Docker image to use for the Nginx
  ingress.
- `nginx_resources` `(Resources: { cpu: 200, memory: 256 })` - The
  resources to assign to the Nginx ingress task.

#### Port

- `name` `(string)` - The label for the port.
- `port` `(number)` - The port number.
- `host_network` `(string)` - The Nomad client host network to assign this port.

#### Resources

- `cpu` `(number)` - The CPU requirement in MHz.
- `memory` `(number)` - The memory requirement in MB.

## Service keys

These are the `meta` and `tags` that you can use when configuring a service to
use the Nginx ingress.

- `nomad_ingress_enabled` - Set this to `true` to register the service in the
  ingress.
- `nomad_ingress_hostname` - The hostname to use to route traffic to this
  service.
- `nomad_ingress_path` - The URL path to use to route traffic to this service.
- `nomad_ingress_port` - The port to use to route traffic to this service.
- `nomad_ingress_allow` - A string of comma-separated IPs or IP CIDR ranges that
  are allowed to access this service.
- `nomad_ingress_deny` - A string of comma-separated IPs or IP CIDR ranges that
  are denied from accessing this service.

[`fake-service`]: https://github.com/nicholasjackson/fake-service
[nomad_docs_faq]: https://www.nomadproject.io/docs/faq#q-how-to-connect-to-my-host-network-when-using-docker-desktop-windows-and-macos
