# WordPress

This pack contains a service job that runs [WordPress](https://wordpress.org/) in a single Nomad client. It currently supports
being run by the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

It has 3 tasks:
- **WordPress:** [*(reference)*](https://wordpress.org/) the open-source CMS;
- **MariaDB:** [*(reference)*](https://mariadb.org/) the database used by WordPress;
- **phpMyAdmin:** [*(reference)*](https://www.phpmyadmin.net/) to handle the administration of MariaDB over web.

Setup:
- Service-to-service communication is handled with Consul Connect (via sidecar proxies);
- MariaDB's state is persisted with Nomad Host Volumes;
- Consul service registration and service health checks are enabled by default for WordPress and phpMyAdmin. MariaDB only has service registration enabled.

## Requirements
Clients that expect to run this job require:
- [Docker volumes](https://www.nomadproject.io/docs/drivers/docker "Docker volumes") to be enabled within their Docker plugin stanza, due to the usage of Nomad's host volume:
```hcl
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
```

- [Host volume](https://www.nomadproject.io/docs/configuration/client#host_volume-stanza "Host volume") to be enabled in the client configuration (the host volume directory - /var/lib/mariadb - must be created in advance):
```hcl
client {
  host_volume "wordpress-mariadb" {
    path      = "/var/lib/mariadb"
    read_only = false
  }
}
```

- [CNI plugins installed](https://www.nomadproject.io/docs/job-specification/network#network-modes "CNI plugins installed") and [its path](https://www.nomadproject.io/docs/configuration/client#cni_path "its path") set in the client's configuration if network mode is set to bridge.

- [Consul Connect](https://www.nomadproject.io/docs/integrations/consul-connect "Consul Connect") to be enabled in Consul's configuration:
```hcl
ports {
  grpc = 8502
}

connect {
  enabled = true
}
```

## Customizing the Docker images

The 3 docker images can be replaced by using their variable names:
- mariadb_task_image
- wordpress_task_image
- phpmyadmin_task_image

Example:
```
nomad-pack run wordpress --var wordpress_task_image="wordpress:5.8.1-apache"
```

## Customizing the environment variables

The 3 tasks have default environment variables. However, it's recommended to change the ones related to authentication if the services are going to be publicly accessible. Additional environment variables can be passed to nomad-pack, even if not in the default variables file.

Default MariaDB environment variables:
```
mariadb_task_env_vars = [
  {
    key = "MYSQL_ROOT_PASSWORD"
    value = "mariadb_root_password"
  },
  {
    key = "MYSQL_DATABASE"
    value = "wordpress"
  },
  {
    key = "MYSQL_USER"
    value = "wordpress"
  },
  {
    key = "MYSQL_PASSWORD"
    value = "wordpress"
  }
]
```

Default WordPress environment variables:
```
wordpress_task_env_vars = [
  {
    key = "WORDPRESS_DB_HOST"
    value = "$${NOMAD_UPSTREAM_ADDR_mariadb}"
  },
  {
    key = "WORDPRESS_DB_USER"
    value = "wordpress"
  },
  {
    key = "WORDPRESS_DB_PASSWORD"
    value = "wordpress"
  },
  {
    key = "WORDPRESS_DB_NAME"
    value = "wordpress"
  }
]
```

Default phpMyAdmin environment variables:
```
phpmyadmin_task_env_vars = [
  {
    key = "MYSQL_ROOT_PASSWORD"
    value = "mariadb_root_password"
  },
  {
    key = "PMA_HOST"
    value = "$${NOMAD_UPSTREAM_IP_mariadb}"
  },
  {
    key = "PMA_PORT"
    value = "$${NOMAD_UPSTREAM_PORT_mariadb}"
  },
  {
    key = "MYSQL_USERNAME"
    value = "wordpress"
  }
]
```

## Customizing Ports

MariaDB ports are not exposed and communication to it needs to be done via its sidecar proxy.

WordPress and phpMyAdmin port 80 are exposed and are randomly assigned to the host. The usage of a reverse proxy, such as Traefik, is recommended.

## Customizing Resources

The application resource limits can be customized on a task level. The variables names are:
- mariadb_task_resources
- wordpress_task_resources
- phpmyadmin_task_resources

Example:
```
wordpress_task_resources = {
  cpu = 1024
  memory = 2048
}
```

## Customizing service health checks

Health checks can be disabled on a service basis. Setting the following variables to *false* will completely disable health checks:
- mariadb_group_has_health_check
- wordpress_group_has_health_check
- phpmyadmin_group_has_health_check

Health check configuration is set by the following variables:
- mariadb_group_health_check
- wordpress_group_health_check
- phpmyadmin_group_health_check

Example:
```
wordpress_group_health_check = {
  name     = "wordpress"
  path     = "/wp-admin/install.php"
  port     = "http"
  interval = "10s"
  timeout  = "2s"
}
```
