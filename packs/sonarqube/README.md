# sonarqube-nomad-pack

This pack contains a service job that runs Sonarqube in Nomad. It currently supports being run by the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

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

- [Host volume](https://www.nomadproject.io/docs/configuration/client#host_volume-stanza "Host volume") to be enabled in the client configuration (the host volume directory - /opt/sonarqube/data - must be created in advance):
```hcl
client {
  host_volume "sonarqube" {
    path      = "/opt/sonarqube/data"
    read_only = false
  }
}
```

- If you're running on Linux, you must ensure that the user running SonarQube can open at least 131072 file descriptors and at least 8192 threads. You can set these values dynamically by running the following commands as root:
```
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
```

## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name.
- `region` (string) - The region where the job should be placed.
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement.
- `namespace` (string) - The namespace where the job should be placed.
- `constraints` (list of objects) - Constraints to apply to the entire job.
- `image_name` (string) - The docker image name.
- `image_tag` (string) - The docker image tag.
- `task_resources` (object, number number) - Resources used by sonarqube task.
- `register_consul_service` (bool) - If you want to register a consul service for the job.
- `consul_service_name` (string) - The consul service name for the application.
- `consul_service_tags` (list of strings) - The consul service name for the application.
- `volume_name` (string) - The name of the volume you want Sonarqube to use.
- `volume_type` (string) - The type of the volume you want Sonarqube to use.
- `sonarqube_env_vars` (map of strings) - Environment variables to pass to Docker container.

## Environment variables

The embedded H2 database is used by default. Additional environment variables can be passed to `sonarqube_env_vars`.

```
sonarqube_env_vars = [
  {
    key = "SONAR_JDBC_URL"
    value = "database connection URL"
  },
  {
    key = "SONAR_JDBC_USERNAME"
    value = "sonar"
  },
  {
    key = "SONAR_JDBC_PASSWORD"
    value = "sonar"
  }
]
```