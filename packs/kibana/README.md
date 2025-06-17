# Kibana

This pack contains all you need to deploy Kibana (version 2 by default) in Nomad. It uses Docker driver.

## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name.
- `region` (string) - The region where jobs will be deployed.
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement.
- `namespace` (string) - The namespace where the job should be placed.
- `constraints` (string) - Constraints to apply to the entire job.
- `image_name` (string) - The docker image name.
- `image_tag` (string) - The docker image tag.
- `task_resources` (object, number number) Resources used by Kibana task
- `register_consul_service` (bool) - If you want to register a consul service for the job
- `consul_service_name` (string) - The consul service name for the Kibana application
- `consul_service_tags` (list of string) - The consul service name for the Kibana application
- `config_volume_name` (string) - The name of the configuration dedicated volume you want Kibana to use
- `config_volume_type` (string) - The type of the configuration dedicated volume you want Kibana to use
- `kibana_keystore_name` (string) - The name of the file to persist Kibana secure settings
- `docker_kibana_env_vars` (map of string) - Environment variables to pass to Docker container
- `kibana_config_file_path` (string) - Kibana configuration file path

## Automated Setup and Persisted Configuration

You have two options:

- __Environment variables way__:
    If you pass the right environment variables to the pack, you can automatically set up Kibana.
    An example of the `docker_kibana_env_vars` to use is in the `vars.nomad` file.

- __Configuration file through volume__:
    You can also mount a volume to persist the configuration file that you can pass through the variable `kibana_config_file_path`.
    You have also to set the `config_volume_name` variable that allows you to mount the volume where you can save the configuration file. Also this in `vars.nomad`.

Pay attention that, if you pass environment variables to set up Kibana AND you use the configuration file volume, the docker environment variables have the precedence.

## Persist the Kibana keystore

To persist your secure settings, use the `kibana-keystore` utility setting `kibana_keystore_name` variable.
