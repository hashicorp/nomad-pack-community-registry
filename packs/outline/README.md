# Outline

This pack contains a service job that runs [Outline](https://www.getoutline.com/) in a single Nomad client. It currently supports
being run by the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

It has 4 tasks:
- **Outline:** [*(reference)*](https://www.getoutline.com/) the wiki and knowledgebase for teams;
- **PostgreSQL:** [*(reference)*](https://www.postgresql.org/) the persistent database used by Outline;
- **Redis:** [*(reference)*](https://redis.io/) for in-memory storage and cache;
- **MinIO:** [*(reference)*](https://min.io/) for images storage, compatible with S3 cloud storage service.

Setup:
- Service-to-service communication is handled with Consul Connect;
- Bitnami images are being used for [PostgreSQL](https://hub.docker.com/r/bitnami/postgresql), [Redis](https://hub.docker.com/r/bitnami/redis) and [MinIO](https://hub.docker.com/r/bitnami/minio). They are non-root containers and as such the mounted files and directories must have the proper permissions for the UID 1001. To achieve this, these 3 images are being run as user 1001 and there are prestart tasks that create their respective directories, while setting the correct ownership, in the host filesystem with the raw exec driver;
- Only MinIO and Outline ports are exposed. To simplify the pack, MinIO has a static host port of 9000, whereas Outline's port is being randomly assigned. In production, it's recommended that none of the services are directly exposed and that traffic is run through a reverse proxy that supports Consul Connect enabled services, like Traefik;
- MinIO's group has a poststart task that applies a policy that disables directory browsing. It does it by finding the correct Docker container, exec'ing into the container and applying the policy with MinIO's MC;
- Outline supports a number of authentication methods. Slack is used for demonstration purposes, but enabling more authentication methods is a matter of defining the [environment variables](https://github.com/outline/outline/blob/main/.env.sample);
- The default variables are defined for a local setup.

## Requirements
Clients that expect to run this job require:
- [Docker volumes](https://www.nomadproject.io/docs/drivers/docker "Docker volumes") to be enabled within their Docker plugin stanza:
```hcl
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
```

- [Raw Exec](https://www.nomadproject.io/docs/drivers/raw_exec "Raw Exec") driver to be enabled:
```hcl
plugin "raw_exec" {
  config {
    enabled = true
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

The 4 docker images can be replaced by using their variable names:
- postgresql_task_image
- minio_task_image
- redis_task_image
- outline_task_image

Example:
```
nomad-pack run outline --var outline_task_image="outlinewiki/outline:0.59.0"
```

## Customizing the environment variables

The 4 tasks have default environment variables. However, it's recommended to change the ones related to authentication if the services are going to be publicly accessible. Additional environment variables can be passed to nomad-pack, even if not in the default variables file.

Default PostgreSQL environment variables:
```
postgresql_task_env_vars = [
  {
    key = "ALLOW_EMPTY_PASSWORD"
    value = "no"
  },
  {
    key = "POSTGRESQL_USERNAME"
    value = "outline_user"
  },
  {
    key = "POSTGRESQL_PASSWORD"
    value = "outline_user_password"
  },
  {
    key = "POSTGRESQL_DATABASE"
    value = "outline"
  }
]
```

Default Redis environment variables:
```
redis_task_env_vars = [
  {
    key = "ALLOW_EMPTY_PASSWORD"
    value = "no"
  },
  {
    key = "REDIS_PASSWORD"
    value = "redis_password"
  }
]
```

Default MinIO environment variables:
```
minio_task_env_vars = [
  {
    key = "MINIO_ROOT_USER"
    value = "minio_root_user"
  },
  {
    key = "MINIO_ROOT_PASSWORD"
    value = "minio_root_password"
  },
  {
    key = "MINIO_BROWSER"
    value = "off"
  },
  {
    key = "MINIO_DEFAULT_BUCKETS"
    value = "outline:none"
  },
  {
    key = "MINIO_FORCE_NEW_KEYS"
    value = "yes"
  }
]
```

Default Outline environment variables:
```
outline_task_env_vars = [
  {
    key = "SECRET_KEY"
    value = "d1434eff0725153e1cc457a013b53dbcdba6a2b40f00729be5680b56fc003897"
  },
  {
    key = "UTILS_SECRET"
    value = "d5c59234b0018fe6036b0376d022c7f5187feb8cc1769c7bc4c282ed8a983b54"
  },
  {
    key = "REDIS_URL"
    value = "redis://:redis_password@$${NOMAD_UPSTREAM_ADDR_outline-redis}"
  },
  {
    key = "DATABASE_URL"
    value = "postgres://outline_user:outline_user_password@$${NOMAD_UPSTREAM_ADDR_outline-postgresql}/outline"
  },
  {
    key = "DATABASE_URL_TEST"
    value = "postgres://outline_user:outline_user_password@$${NOMAD_UPSTREAM_ADDR_outline-postgresql}/outline_test"
  },
  {
    key = "PGSSLMODE"
    value = "disable"
  },
  {
    key = "URL"
    value = "http://localhost:3000"
  },
  {
    key = "PORT"
    value = "3000"
  },
  {
    key = "AWS_ACCESS_KEY_ID"
    value = "minio_root_user"
  },
  {
    key = "AWS_SECRET_ACCESS_KEY"
    value = "minio_root_password"
  },
  {
    key = "AWS_REGION"
    value = "us-east-1"
  },
  {
    key = "AWS_S3_UPLOAD_BUCKET_URL"
    value = "http://localhost:9000"
  },
  {
    key = "AWS_S3_UPLOAD_BUCKET_NAME"
    value = "outline"
  },
  {
    key = "AWS_S3_UPLOAD_MAX_SIZE"
    value = "26214400"
  },
  {
    key = "AWS_S3_FORCE_PATH_STYLE"
    value = "true"
  },
  {
    key = "AWS_S3_ACL"
    value = "private"
  },
  {
    key = "SLACK_KEY"
    value = "123123"
  },
  {
    key = "SLACK_SECRET"
    value = "123123"
  },
  {
    key = "FORCE_HTTPS"
    value = "false"
  },
  {
    key = "ENABLE_UPDATES"
    value = "no"
  },
  {
    key = "WEB_CONCURRENCY"
    value = "1"
  },
  {
    key = "MAXIMUM_IMPORT_SIZE"
    value = "5120000"
  },
  {
    key = "DEBUG"
    value = "http"
  },
  {
    key = "DEFAULT_LANGUAGE"
    value = "en_US"
  }
]
```

## Customizing ports

PostgreSQL and Redis ports are not exposed and communication to it needs to be done via its sidecar proxy.

Outline's ports is exposed and randomly assigned to the host.

MinIO port is exposed to the host and static.

The usage of a reverse proxy, such as Traefik, is highly recommended.

## Customizing resources

The application resource limits can be customized on a task level. The variables names are:
- outline_task_resources
- postgresql_task_resources
- redis_task_resources
- minio_task_resources

Example:
```
outline_task_resources = {
  cpu = 1024
  memory = 2048
}
```

## Setting the host paths

PostgreSQL, Redis and MinIO are using bind mounts for storage persistence.
The path for the mounts can be replaced through the following variables:
- postgresql_task_volume_path
- redis_task_volume_path
- minio_task_volume_path

Example:
```
nomad-pack run outline --var postgresql_task_volume_path="/var/lib/outline/postgresql"
```
