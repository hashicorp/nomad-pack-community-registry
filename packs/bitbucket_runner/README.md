# Runner for BitBucket Pipelines

This pack creates a Nomad job that runs a Bitbucket pipeline runner instance.
You get the required configuration/environment variables when adding the runner on the Bitbucket website.

## Variables

- `constraints` (list of object) - Constraints for scheduling running the job
- `container_image` (object) - Container image and version to use
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement
- `instances` (number) - The number of instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `namespace` (string) - The Nomad namespace to run the job in. (NOTE: not 100% supported in 0.0.1)
- `network_mode` (string) - Network mode to use.
- `priority` (number) - The job priority
- `region` (string) - The region where jobs will be deployed
- `task_resources` (object) - Resources to assign the runner task
- `task_mounts` (list of object) - Folders to map to the task
- `task_environment` (map of string) - Environment variables used for configuration.
- `task_services` (list of object) - Register consul services

## Dependencies

- Linux Nomad client required.
- Nomad client has to support running as privileged container for creating sub-containers in pipeline.

## Example use
```hcl
# example.hcl
job_name = "example1"
task_environment = {
  ACCOUNT_UUID = "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}"
  RUNNER_UUID = "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}"
  RUNTIME_PREREQUISITES_ENABLED = "true"
  OAUTH_CLIENT_ID = "12345678901234567890123456789012"
  OAUTH_CLIENT_SECRET = "abcd_xxxxxxxxxxx__xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  WORKING_DIRECTORY = "/tmp"
}
```

```bash
# Use config from file
nomad-pack render bitbucket_runner --var-file example.hcl

# Config in file w/override variable
nomad-pack render bitbucket_runner --var-file example.hcl --var "job_name=example2"

# Run job
export NOMAD_ADDR=<your address>
export NOMAD_TOKEN=<your token>
nomad-pack run bitbucket_runner --var-file example.hcl --var "job_name=bbruner"
```
