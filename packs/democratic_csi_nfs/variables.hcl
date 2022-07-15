variable "job_name" {
  description = "The prefix to use as the job name for the plugins (ex. democratic_csi_controller for the controller)."
  type        = string
  default     = "democratic_csi"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "plugin_id" {
  description = "The ID to register in Nomad for the plugin."
  type        = string
  default     = "org.democratic-csi.nfs"
}

variable "plugin_namespace" {
  description = "The namespace for the plugin job."
  type        = string
  default     = "default"
}

variable "plugin_image" {
  description = "The container image for democratic-csi."
  type        = string
  default     = "docker.io/democraticcsi/democratic-csi:latest"
}

variable "plugin_csi_spec_version" {
  description = "The CSI spec version that democratic-csi will comply with."
  type        = string
  default     = "1.5.0"
}

variable "plugin_log_level" {
  description = "The log level for the plugin."
  type        = string
  default     = "debug"
}

variable "nfs_share_host" {
  description = "The IP address of the host for the NFS share."
  type        = string
}

variable "nfs_share_base_path" {
  description = "The base directory exported from the NFS share host."
  type        = string
}

variable "nfs_controller_mount_path" {
  description = "The path where the NFS mount is mounted as a host volume for the controller plugin."
  type        = string
}

variable "nfs_dir_permissions_mode" {
  description = "The unix file permissions mode for the created volumes"
  type        = string
  default     = "0777"
}

variable "nfs_dir_permissions_user" {
  description = "The unix user that owns the created volumes."
  type        = string
  default     = "root"
}

variable "nfs_dir_permissions_group" {
  description = "The unix group that owns the created volumes."
  type        = string
  default     = "root"
}

variable "controller_count" {
  description = "The number of controller instances to be deployed (at least 2 recommended)."
  type        = number
  default     = 2
}

variable "constraints" {
  description = "Additional constraints to apply to the jobs."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "resources" {
  description = "The resources to assign to the plugin tasks."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}

variable "volume_id" {
  description = "ID for the example volume spec to output."
  type        = string
  default     = "myvolume"
}

variable "volume_namespace" {
  description = "Namespace for the example volume spec to output."
  type        = string
  default     = "default"
}
