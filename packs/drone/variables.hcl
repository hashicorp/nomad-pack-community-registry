# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for job placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "node_pool" {
  description = "The node pool where the job should be placed."
  type        = string
  default     = "default"
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
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
      operator  = "",
    },
  ]
}

variable "group_network" {
  description = "The Drone network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "drone-server" = 80,
      "drone-agent"  = 3000,
    },
  }
}

variable "drone_server_image" {
  description = "The Drone Server image."
  type        = string
  default     = "drone/drone"
}

variable "drone_server_version" {
  description = "The Drone Server image version."
  type        = string
  default     = "2.1.0"
}

variable "drone_server_cfg" {
  description = "The Drone Server configuration."
  type        = string
  default     = <<EOF
DRONE_USER_CREATE=username:admin,machine:false,admin:true
DRONE_SERVER_HOST=drone.service.consul
DRONE_SERVER_PROTO=http
DRONE_RPC_SECRET=K3qXXoxoBetLkfBx3y69WotJNVM2MH4
EOF
}

variable "drone_agent_image" {
  description = "The Drone Agent image."
  type        = string
  default     = "drone/drone-runner-nomad"
}

variable "drone_agent_version" {
  description = "The Drone Agent image version."
  type        = string
  default     = "latest"
}

variable "drone_agent_cfg" {
  description = "The Drone Agent configuration."
  type        = string
  default     = <<EOF
DRONE_JOB_DATACENTER=global
DRONE_RPC_HOST=drone.service.consul
DRONE_RPC_PROTO=http
DRONE_RPC_SECRET=K3qXXoxoBetLkfBx3y69WotJNVM2MH4
NOMAD_ADDR=http://nomad.service.consul:4646
EOF
}

variable "server_task_resources" {
  description = "The resource to assign to the Drone Server task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 250,
    memory = 512,
  }
}

variable "agent_task_resources" {
  description = "The resource to assign to the Drone Agent task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 250,
    memory = 1024,
  }
}

variable "task_services" {
  description = "Configuration options of the Drone services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_interval     = string
    check_timeout      = string
    check_type         = string
  }))
  default = [{
    service_port_label = "drone-server",
    service_name       = "drone",
    service_tags       = [],
    check_interval     = "3s",
    check_timeout      = "1s",
    check_type         = "tcp",
  }]
}
