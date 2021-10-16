variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "cloud_conf_file" {
  description = "Path to custom cloud.conf file to be mounted to the CSI containers. For reference, see https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#global"
  type		= string
  default = ""
}

variable "csi_plugin_id" {
  description = "The ID to register the CSI plugin with."
  type		    = string
  default     = "csi-cinder"
}

variable "csi_driver_log_level" {
  description = "Set the CSI Drivers log verbosity. From 1-5, increasing verbosity with each higher value"
  type		    = number
  default     = 3
}

variable "vault_config" {
  description = "Nomad Job Vault Configuration. Set `enabled = true` to configure the job to use vault See: https://www.nomadproject.io/docs/job-specification/vault"
  type = object({
    enabled       = bool
    policies      = list(string)
    change_mode   = string
    change_signal = string
    env           = bool
    namespace     = string
  })
  default = {
    enabled       = false
    policies      = []
    change_mode   = "restart"
    change_signal = ""
    env           = true
    namespace     = ""
  }
}