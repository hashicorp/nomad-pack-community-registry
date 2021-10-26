# Openstack Cinder CSI

This pack deploys the Openstack Cinder CSI container as a system job to all eligible Nomad Clients.

See the Openstack Cinder CSI documentation for more information: https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md

## Dependencies

This pack requires the Nomad Client(s) be deployed on an Openstack VM that can have Cinder Volumes attached to it.

## Container Privilege

The Cinder Node task containers run as ***Privileged*** containers. The Cinder Controller tasks do not require privileged mode.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name | `string` | `""` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed | `string` | `"global"` | no |
| <a name="input_constraints"></a> [constraints](#input\_constraints) | Constraints to apply to the entire job. | <pre>list(object({<br>    attribute = string<br>    operator  = string<br>    value     = string<br>  }))</pre> | <pre>[<br>  {<br>    "attribute": "${attr.platform.aws.placement.availability-zone}",<br>    "operator": "",<br>    "value": "nova"<br>  }<br>]</pre> | no |
| <a name="input_job_restart_config"></a> [job\_restart\_config](#input\_job\_restart\_config) | n/a | <pre>object({<br>      attempts = number<br>      delay    = string<br>      mode     = string<br>      interval = string<br>    })</pre> | <pre>{<br>  "attempts": 5,<br>  "delay": "15s",<br>  "interval": "5m",<br>  "mode": "delay"<br>}</pre> | no |
| <a name="input_cloud_conf_file"></a> [cloud\_conf\_file](#input\_cloud\_conf\_file) | Path to custom cloud.conf file to be mounted to the CSI containers. For reference, see https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#global | `string` | `""` | no |
| <a name="input_csi_plugin_id"></a> [csi\_plugin\_id](#input\_csi\_plugin\_id) | The ID to register the CSI plugin with. | `string` | `"csi-cinder"` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | The docker image version. For options, see https://hub.docker.com/r/k8scloudprovider/cinder-csi-plugin | `string` | `"latest"` | no |
| <a name="input_cinder_node_args"></a> [cinder\_node\_args](#input\_cinder\_node\_args) | Arguments passed to the Cinder CSI Node docker container | `list(string)` | <pre>[<br>  "/bin/cinder-csi-plugin",<br>  "-v=3",<br>  "--endpoint=unix:///csi/csi.sock",<br>  "--cloud-config=/etc/config/cloud.conf"<br>]</pre> | no |
| <a name="input_cinder_controller_args"></a> [cinder\_controller\_args](#input\_cinder\_controller\_args) | Arguments passed to the Cinder CSI Node docker container | `list(string)` | <pre>[<br>  "/bin/cinder-csi-plugin",<br>  "-v=3",<br>  "--endpoint=unix:///csi/csi.sock",<br>  "--cloud-config=/etc/config/cloud.conf"<br>]</pre> | no |
| <a name="input_vault_config"></a> [vault\_config](#input\_vault\_config) | Nomad Job Vault Configuration. Set `enabled = true` to configure the job to use vault See: https://www.nomadproject.io/docs/job-specification/vault | <pre>object({<br>    enabled       = bool<br>    policies      = list(string)<br>    change_mode   = string<br>    change_signal = string<br>    env           = bool<br>    namespace     = string<br>  })</pre> | <pre>{<br>  "change_mode": "restart",<br>  "change_signal": "",<br>  "enabled": false,<br>  "env": true,<br>  "namespace": "",<br>  "policies": []<br>}</pre> | no |
