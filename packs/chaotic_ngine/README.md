# Chaotic Ngine

This pack contains a batch job that runs [Chaotic](https://github.com/ngine-io/chaotic).

## Dependencies

None

## Variables
- `nomad_addr` (string) - Address to the Nomad API, e.g. "http://172.17.0.1:4646"
- `config_template_url` (string) - URL to the config resource in JSON format. Mutually exclusive with `config`.
- `config` (string) - Config to be used. Mutually exclusive with `config_template_url`.
- `cron` (string) - The cron, when the batch job should run, default "13 * * * * *"
- `timezone` (string) - The timezone, default "Etc/UTC"
- `image_version` (string) - The docker image version. For options, see: https://gitlab.com/ngine/docker-images/chaotic/container_registry/
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed
- `namespace` (string) - The namespace where the job should be placed in
- `priority` (number) - The job priority

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Chaotic task will run.

- `attribute` (string) - Specifies the name or reference of the attribute to examine for the
  constraint.
- `operator` (string) - Specifies the comparison operator. The ordering is compared lexically.
- `value` (string) - Specifies the value to compare the attribute against using the specified
  operation.

The default value constrains the job to run on client whose kernel name is `linux`. The HCL
variable list of objects is shown below and uses a double dollar sign for escaping:
```hcl
[
  {
    attribute = "$${attr.kernel.name}",
    value = "linux",
    operator = "",
  }
]
```

[job_constraint]: (https://www.nomadproject.io/docs/job-specification/constraint)
