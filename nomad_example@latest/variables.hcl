variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
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

variable cache_redis_task {
  description = "Configuration options for the Redis task within the cache group."
  type = object({
    driver          = string
    image_version   = string
    port_6379_label = string
  })
  default = {
    driver          = "docker",
    image_version   = "3.2",
    port_6379_label = "db"
  }
}

variable "cache_redis_resources" {
  description = "The resource to assign to the Redis task within the cache group."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}
