variable "job_name" {
  description = "The name to use as the job name for the plugins nodes."
  type        = string
  default     = "aws-efs-csi-nodes"
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

variable "image" {
  description = "Docker image to run on the nodes."
  type        = string
  default     = "amazon/aws-efs-csi-driver:master"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = null,
    }, 
    {
      attribute = "$${attr.driver.docker.privileged.enabled}",
      value     = true,
      operator  = null,
    }
  ]
}

variable "resources" {
  description = "The resources to allocate for the plugins tasks."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100,
    memory = 128,
  }
}

variable "csi_id" {
  description = "ID to assign to the CSI plugin"
  type = string
  default = "aws-efs"
}
