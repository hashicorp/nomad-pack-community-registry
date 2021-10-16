# Openstack Cinder CSI

This pack deploys the Openstack Cinder CSI container as a system job to all eligible Nomad Clients.

See the Openstack Cinder CSI documentation for more information: https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md

## Dependencies

This pack requires the Nomad Client(s) be deployed on an Openstack VM that can have Cinder Volumes attached to it.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name | `string` | `""` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed | `string` | `"global"` | no |
| <a name="input_cloud_conf_file"></a> [cloud\_conf\_file](#input\_cloud\_conf\_file) | Path to custom cloud.conf file to be mounted to the CSI containers. For reference, see https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#global | `string` | `""` | no |
| <a name="input_csi_plugin_id"></a> [csi\_plugin\_id](#input\_csi\_plugin\_id) | The ID to register the CSI plugin with. | `string` | `"csi-cinder"` | no |
| <a name="input_vault_config"></a> [vault\_config](#input\_vault\_config) | Nomad Job Vault Configuration. Set `enabled = true` to configure the job to use vault See: https://www.nomadproject.io/docs/job-specification/vault | <pre>object({<br>    enabled       = bool<br>    policies      = list(string)<br>    change_mode   = string<br>    change_signal = string<br>    env           = bool<br>    namespace     = string<br>  })</pre> | <pre>{<br>  "change_mode": "restart",<br>  "change_signal": "",<br>  "enabled": false,<br>  "env": true,<br>  "namespace": "",<br>  "policies": []<br>}</pre> | no |
| <a name="input_csi_driver_log_level"></a> [csi\_driver\_log\_level](#input\_csi\_driver\_log\_level) | Set the CSI Drivers log verbosity. From 1-5, increasing verbosity with each higher value | `number` | `3` | no |
