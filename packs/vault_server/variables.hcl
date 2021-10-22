variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = ""
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

variable "namespace" {
  description = "The namespace where the job should be placed"
  type        = string
  default     = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job; useful to potentially ensure distinct hosts."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "vault_server_group_count" {
  description = "The number of Vault server task groups to run."
  type        = number
  default     = 3
}

variable "vault_server_group_network" {
  description = ""
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "http"         = 8200,
      "cluster-http" = 8201,
    },
  }
}

variable "vault_server_task" {
  description = ""
  type        = object({
    driver              = string
    version             = string
    additional_cli_args = list(string)
  })
  default = {
    driver              = "docker"
    version             = "1.8.4",
    additional_cli_args = [],
  }
}

variable "vault_server_task_config" {
  description = ""
  type        = string
  default     = <<EOH
storage "raft" {
  path    = "local/"
  node_id = "vault-server-{{ env "NOMAD_ALLOC_INDEX" }}"
}

ui            = true
disable_mlock = true

listener "tcp" {
  tls_disable     = 1
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
}

api_addr = "http://{{ env "NOMAD_NET_NAMESPACE_ADDR_http" }}"
cluster_addr = "http://{{ env "NOMAD_NET_NAMESPACE_ADDR_cluster-http" }}"

{{- range service "vault-server-cluster-http" }}
retry_join {
  leader_api_addr = "http://{{ .Address }}:{{ .Port }}"
}
{{- end }}
EOH
}

variable "vault_server_task_resources" {
  description = "The resource to assign to the Vault server task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256,
  }
}

variable "vault_server_task_services" {
  description = "Configuration options of the Vault server services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_type         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [
    {
      service_port_label = "http",
      service_name       = "vault-server-http",
      service_tags       = ["traefik.enable=true", "traefik.http.routers.http.rule=Path(`/vault/`)"],
      check_enabled      = true,
      check_path         = "/v1/sys/health?standbyok=true"
      check_type         = "http",
      check_interval     = "3s",
      check_timeout      = "1s",
    },
    {
      service_port_label = "cluster-http",
      service_name       = "vault-server-cluster-http",
      service_tags       = [],
      check_enabled      = false,
      check_path         = "",
      check_type         = "",
      check_interval     = "",
      check_timeout      = "",
    },
  ]
}
