# Nomad pack for Terraform Enterprise FDO

This pack deploys Terraform Enterprise on Nomad. This includes running a Terraform Enterprise service job and Terraform Enterprise agent batch job.

## Pack Usage

The pack expects certain prerequisites to be fulfilled before running. The list of prerequisites are:

### Installation Requirements

Follow this page for [installation requirements](https://developer.hashicorp.com/terraform/enterprise/flexible-deployments/install/requirements).

### Create Environment variables
1. `NOMAD_ADDR` - The address of the Nomad server.
1. `NOMAD_TOKEN` - The SecretID of an ACL token to use to authenticate API requests with. You will need this to create Nomad namespaces, variables and ACLs.
1. `NOMAD_CACERT` - Path to a PEM encoded CA cert file to use to verify the Nomad server SSL certificate.
1. `NOMAD_CLIENT_CERT` - Path to a PEM encoded client certificate for TLS authentication to the Nomad server. Must also specify NOMAD_CLIENT_KEY.
1. `NOMAD_CLIENT_KEY` - Path to an unencrypted PEM encoded private key matching the client certificate from NOMAD_CLIENT_CERT.

### Create Namespace for TFE job and TFE agent job.

   1. Run `nomad namespace apply terraform-enterprise` to create the `terraform-enterprise` namespace. This is the default namespace that is used to bring up TFE Job.
   1. Run `nomad namespace apply tfe-agents` to create the `tfe-agents` namespace. This is the default namespace that is used to bring up TFE Agent Job.


### Create and apply Nomad ACL policy.
Create a file `terraform_enterprise_policy.hcl` with the content below:
```hcl
  namespace "tfe-agents" {
  capabilities = ["submit-job","dispatch-job", "list-jobs", "read-job", "read-logs" ]
  }
  ```

To apply the policy run following bash command:
  ```bash
  $ nomad acl policy apply \
   -namespace terraform-enterprise -job tfe-job \
   -group tfe-group -task tfe-task \
   terraform-enterprise-policy ./terraform_enterprise_policy.hcl
  ``` 

### Create the Nomad Variables. 
  
  These contain sensitive data that are required like certs, licenses and passwords.
  Create a variable specification file: 

  ```hcl
  # spec.nv.hcl

  # Path where Nomad variables will be stored, the same path will be used inside TFE job file rendered by tfe.nomad.tpl for TFE job to access.
  path      = "nomad/jobs/tfe-job"
  namespace = "terraform-enterprise"

  items {
    # TFE DB password. Mapped to the TFE_DB_PASSWORD environment variable.
    db_password = ""

    # The field should contain the base64 encoded value of the cert. Mappped to the TFE_TLS_CERT_FILE environment variable.
    cert = ""

    # The field should contain the base64 encoded value of the bundle. Mapped to the TFE_TLS_CA_BUNDLE_FILE environment variable.
    bundle = ""

    # The field should contain the base64 encoded value of the key. Mappped to the TFE_TLS_KEY_FILE environment variable.
    key = ""
  
    # A valid TFE license. Mapped to the TFE_LICENSE environment variable.
    tfe_license = ""
    
    # Object storage access key. Mapped to the TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY environment variable.
    s3_secret_key = ""

    # TFE Redis password. Mapped to the TFE_REDIS_PASSWORD environment variable.
    redis_password = ""

    # TFE Vault encryption key. Mapped to the TFE_ENCRYPTION_PASSWORD environment variable.
    tfe_encryption_password = ""

    # Password for the registry where the TFE image is hosted. Mapped to the TFE_IMAGE_REGISTRY_PASSWORD environment variable.
    tfe_image_registry_password = ""

  }
  ```
  
  Update the `path` variable if default value of `job_name` is overridden in the `var.hcl` file.
  The variables can be created as below by passing the `spec.nv.hcl` file we create above:

  ```bash
  $ nomad var put @spec.nv.hcl
  ```
**Note: At this point, this file can be deleted.**

## Pack Information

After completing prerequisites, the pack can be run using the following bash command:
```bash
$ nomad-pack run tfe_fdo_nomad -f variables.hcl
```

The `variables.hcl` file should contain the necessary variables required for the pack to run. The variables are listed below.

### Variables

These variables may be set to change the behavior of the TFE. Note that some of these variables come with default configuration while the rest need to provided for the pack deployment to succeed.

### Configuration

| Name                                         | Required | Default                                      | Comments                                                                                                                                                                                                                                                                            |
|----------------------------------------------|----------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `job_name`                                   | no       | `"tfe-job"`                                  | Override the TFE job name.                                                                                                                                                                                                                                                          |
| `tfe_agent_job_id`                           | no       | `"tfe-agent-job"`                            | Override the TFE Agent job name.                                                                                                                                                                                                                                                    |
| `datacenters`                                | no       | `["*"]`                                      | Nomad datacenters where the task in the jobs will be spread.                                                                                                                                                                                                                        |
| `tfe_namespace`                              | no       | `"terraform-enterprise"`                     | Nomad namespace where TFE image will be run as a Nomad task.                                                                                                                                                                                                                        |
| `tfe_port`                                   | no       | `8443`                                       | HTTPS port to expose for TFE task.                                                                                                                                                                                                                                                  |
| `tfe_group_count`                            | no       | `1`                                          | Number of task groups to run in the job. If this is set to more than 1, the `network.port` for `tfe` and `http` inside `tfe.nomad.tpl` needs to be changed from `static` to `to` and NGINX needs to be deployed so that traffic can be routed to any of the deployed TFE instances. |
| `tfe_http_port`                              | no       | `8080`                                       | HTTP port to expose for TFE task.                                                                                                                                                                                                                                                   |
| `tfe_service_name`                           | no       | `"tfe-service"`                              | Name of the service to register in Nomad DNS.                                                                                                                                                                                                                                       |
| `tfe_database_user`                          | no       | `"hashicorp"`                                | TFE database user.                                                                                                                                                                                                                                                                  |
| `tfe_database_host`                          | yes      | `""`                                         | The host name/IP of the postgres database being used.                                                                                                                                                                                                                               |
| `tfe_database_name`                          | no       | `"tfe"`                                      | TFE database name.                                                                                                                                                                                                                                                                  |
| `tfe_database_parameters`                    | no       | `"sslmode=require"`                          | TFE database server parameters for the connection URI.                                                                                                                                                                                                                              |
| `tfe_object_storage_type`                    | no       | `"s3"`                                       | Type of object storage to use. Must be one of s3, azure, or google.                                                                                                                                                                                                                 |
| `tfe_object_storage_s3_bucket`               | no       | `"tfe"`                                      | The bucket name of the S3 compatible object storage being used.                                                                                                                                                                                                                     |
| `tfe_object_storage_s3_region`               | no       | `"us-west-2"`                                | S3 region.                                                                                                                                                                                                                                                                          |
| `tfe_object_storage_s3_use_instance_profile` | no       | `false`                                      | Whether to use the instance profile for authentication.                                                                                                                                                                                                                             |
| `tfe_object_storage_s3_endpoint`             | yes      | `""`                                         | The endpoint of the S3 compatible object storage being used.                                                                                                                                                                                                                        |
| `tfe_object_storage_s3_access_key_id`        | yes      | `""`                                         | The access key id value to be used to query the S3 object storage bucket.                                                                                                                                                                                                           |
| `tfe_redis_host`                             | yes      | `""`                                         | The Redis host name being used.                                                                                                                                                                                                                                                     |
| `tfe_redis_user`                             | no       | `""`                                         | Redis server user.                                                                                                                                                                                                                                                                  |
| `tfe_redis_use_tls`                          | no       | `false`                                      | Indicates to use TLS to access Redis.                                                                                                                                                                                                                                               |
| `tfe_redis_use_auth`                         | no       | `false`                                      | Indicates Redis server is configured to use TFE_REDIS_PASSWORD and TFE_REDIS_USER (optional) for authentication.                                                                                                                                                                    |
| `tfe_hostname`                               | yes      | `""`                                         | The host name of the TFE instance to be used while deploying.                                                                                                                                                                                                                       |
| `tfe_iact_subnets`                           | no       | `""`                                         | Comma-separated list of subnets in CIDR notation that are allowed to retrieve the initial admin creation token via the API .                                                                                                                                                        |
| `tfe_iact_time_limit`                        | no       | `60`                                         | Number of minutes that the initial admin creation token can be retrieved via the API after the application starts.                                                                                                                                                                  |
| `tfe_vault_disable_mlock`                    | no       | `true`                                       | Disable mlock for internal Vault.                                                                                                                                                                                                                                                   |
| `tfe_resource_cpu`                           | no       | `750`                                        | CPU in MHz for TFE container.                                                                                                                                                                                                                                                       |
| `tfe_resource_memory`                        | no       | `1024`                                       | Memory in MB for TFE container.                                                                                                                                                                                                                                                     |
| `tfe_image`                                  | no       | `"hashicorp/terraform-enterprise:v202401-2"` | TFE image and tag to download and run.                                                                                                                                                                                                                                              |
| `tfe_image_registry_username`                | no       | `"terraform"`                                | The user name for the registry where the TFE image is hosted.                                                                                                                                                                                                                       |
| `tfe_image_server_address`                   | no       | `"images.releases.hashicorp.com"`            | The server address of the registry where TFE image is hosted.                                                                                                                                                                                                                       |
| `tfe_agent_namespace`                        | no       | `"tfe-agents"`                               | Nomad namespace for TFE Agents to run.                                                                                                                                                                                                                                              |
| `tfe_agent_image`                            | no       | `"hashicorp/tfc-agent:latest"`               | TFE Agent image and tag to download and run.                                                                                                                                                                                                                                        |
| `tfe_vault_cluster_port`                     | no       | `8201`                                       | Vault cluster port which needs to exposed from the TFE container.                                                                                                                                                                                                                   |
| `tfe_vault_cluster_address`                  | no       | `"http://$${NOMAD_HOST_ADDR_vault}"`         | Cluster URL of the internal Vault server on this node (e.g., http://192.168.0.1:8201). Must be reachable across nodes.                                                                                                                                                              |
| `tfe_agent_resource_cpu`                     | no       | `750`                                        | CPU in MHz for TFE Agent container.                                                                                                                                                                                                                                                 |
| `tfe_agent_resource_memory`                  | no       | `1024`                                       | Memory in MB for TFE Agent container.                                                                                                                                                                                                                                               |
| `tfe_service_discovery_provider`             | no       | `"nomad"`                                    | Specifies the service registration provider to use for service registrations. Valid options are either consul or nomad. All services within a single task group must utilise the same provider value.                                                                               |
| `health_check_interval`                      | no       | `"5s"`                                       | Specifies the interval at which Nomad will call the health check API for TFE container.                                                                                                                                                                                             |
| `health_check_timeout`                       | no       | `"2s"`                                       | Specifies the timeout in case health check API of TFE container is not reachable from Nomad.                                                                                                                                                                                        |
