variable "job_name" {
  type        = string
  description = "The name of the Nomad job."
  default     = "openstudio-server"
}

variable "app_version" {
  type        = string
  description = "Application version tag used for OpenStudio Server component images."
  default     = "latest"
}

variable "worker_min_replicas" {
  type        = number
  description = "Minimum number of worker replicas."
  default     = 1
}

variable "worker_max_replicas" {
  type        = number
  description = "Maximum number of worker replicas."
  default     = 10
}

variable "vault_integration_enabled" {
  type        = bool
  description = "Enable Nomad Vault integration stanzas for tasks."
  default     = false
}

variable "ingress_domain" {
  type        = string
  description = "Ingress domain used when constructing service hostnames and Traefik router rules."
  default     = "localhost"
}

variable "ingress_tls_enabled" {
  type        = bool
  description = "When true, adds Traefik TLS router tags for the websecure entrypoint on the web service."
  default     = false
}

variable "nomad_namespace" {
  type        = string
  description = "The Nomad namespace in which all pack jobs are registered. Use 'default' for the built-in namespace."
  default     = "default"
}

variable "region" {
  type        = string
  description = "The Nomad region where the job will be deployed."
  default     = "global"
}

variable "datacenters" {
  type        = list(string)
  description = "A list of datacenters in the region which are eligible for task placement."
  default     = ["dc1"]
}

# Image versions / repositories
variable "web_image" {
  type        = string
  description = "The image name and tag for the OpenStudio Server web container."
  default     = "nrel/openstudio-server:latest"
}

variable "web_priority" {
  type        = number
  description = "Nomad job priority for the OpenStudio Web UI job."
  default     = 80
}

variable "web_cpu" {
  type        = number
  description = "CPU shares allocated to the OpenStudio Web task."
  default     = 1000
}

variable "web_memory" {
  type        = number
  description = "Memory (MB) allocated to the OpenStudio Web task."
  default     = 2048
}

variable "web_memory_max" {
  type        = number
  description = "Memory hard limit (MB) for the OpenStudio Web task (Nomad memory_max)."
  default     = 2048
}

variable "web_count" {
  type        = number
  description = "The number of web task group allocations."
  default     = 1
}

variable "web_port" {
  type        = number
  description = "Host-side static port mapped to the web container HTTP port."
  default     = 80
}

variable "web_health_check_interval" {
  type        = string
  description = "Interval between Consul health checks for the web service."
  default     = "10s"
}

variable "web_health_check_timeout" {
  type        = string
  description = "Timeout for Consul health checks for the web service."
  default     = "2s"
}

variable "web_update_max_parallel" {
  type        = number
  description = "Maximum number of web allocations updated in parallel."
  default     = 1
}

variable "web_update_health_check" {
  type        = string
  description = "Health check mode for web rolling updates."
  default     = "checks"
}

variable "web_update_min_healthy_time" {
  type        = string
  description = "How long a web allocation must remain healthy before promotion."
  default     = "30s"
}

variable "web_update_healthy_deadline" {
  type        = string
  description = "Maximum time for a web allocation to become healthy."
  default     = "5m"
}

variable "web_update_progress_deadline" {
  type        = string
  description = "Maximum time for the web rolling update to make progress."
  default     = "10m"
}

variable "web_update_auto_revert" {
  type        = bool
  description = "Automatically revert a web deployment if the update fails."
  default     = true
}

variable "web_background_cpu" {
  type        = number
  description = "CPU shares allocated to the OpenStudio web-background task."
  default     = 250
}

variable "web_background_memory" {
  type        = number
  description = "Memory (MB) allocated to the OpenStudio web-background task."
  default     = 512
}

variable "worker_image" {
  type        = string
  description = "The image name and tag for the OpenStudio Server worker container."
  default     = "nrel/openstudio-server:latest"
}

variable "worker_count" {
  type        = number
  description = "The number of worker task group allocations."
  default     = 1
}

variable "worker_update_max_parallel" {
  type        = number
  description = "Maximum number of worker allocations updated in parallel."
  default     = 1
}

variable "worker_update_health_check" {
  type        = string
  description = "Health check mode for worker rolling updates."
  default     = "task_states"
}

variable "worker_update_min_healthy_time" {
  type        = string
  description = "How long a worker allocation must remain healthy before promotion."
  default     = "30s"
}

variable "worker_update_healthy_deadline" {
  type        = string
  description = "Maximum time for a worker allocation to become healthy."
  default     = "5m"
}

variable "worker_update_progress_deadline" {
  type        = string
  description = "Maximum time for the worker rolling update to make progress."
  default     = "10m"
}

variable "worker_update_auto_revert" {
  type        = bool
  description = "Automatically revert a worker deployment if the update fails."
  default     = true
}

variable "worker_priority" {
  type        = number
  description = "Nomad job priority for calculation workers."
  default     = 40
}

variable "worker_queues" {
  type        = string
  description = "Comma-separated queue list processed by worker tasks."
  default     = "requeued,simulations"
}

variable "worker_process_count" {
  type        = string
  description = "COUNT environment variable passed to worker containers."
  default     = "1"
}

variable "worker_cpu" {
  type        = number
  description = "CPU shares allocated to the OpenStudio worker task. These defaults are intentionally higher than Helm to support higher simulation concurrency per Nomad allocation."
  default     = 2000
}

variable "worker_memory" {
  type        = number
  description = "Memory (MB) allocated to the OpenStudio worker task. These defaults are intentionally higher than Helm to support higher simulation concurrency per Nomad allocation."
  default     = 4096
}

variable "worker_autoscaling_enabled" {
  type        = bool
  description = "Enable Nomad Autoscaler integration for the worker task group. When false (default), the scaling block is omitted and worker_count controls the fixed allocation count."
  default     = false
}

variable "nomad_autoscaler_enabled" {
  type        = bool
  description = "Render an optional Nomad Autoscaler daemon job stub. When false (default), the autoscaler job template is omitted."
  default     = false
}

variable "autoscaler_prometheus_address" {
  type        = string
  description = "Address of the Prometheus server used by the Nomad Autoscaler APM plugin to evaluate scaling checks."
  default     = "http://prometheus:9090"
}

variable "autoscaler_cooldown" {
  type        = string
  description = "Cooldown duration between worker autoscaling actions (e.g. '5m', '2m')."
  default     = "5m"
}

variable "worker_queue_requeued_query" {
  type        = string
  description = "Prometheus query for requeued backlog depth."
  default     = "sum(openstudio_worker_queue_depth{queue=\"requeued\"})"
}

variable "worker_queue_requeued_target" {
  type        = number
  description = "Target queue depth for requeued jobs per worker allocation."
  default     = 1
}

variable "worker_queue_simulations_query" {
  type        = string
  description = "Prometheus query for simulations backlog depth."
  default     = "sum(openstudio_worker_queue_depth{queue=\"simulations\"})"
}

variable "worker_queue_simulations_target" {
  type        = number
  description = "Target queue depth for simulation jobs per worker allocation."
  default     = 5
}

variable "web_background_image" {
  type        = string
  description = "The image name and tag for the OpenStudio Server web-background container."
  default     = "nrel/openstudio-server:latest"
}

variable "web_background_count" {
  type        = number
  description = "The number of web-background tasks to run."
  default     = 1
}
variable "db_image" {
  type        = string
  description = "The MongoDB database image name and tag."
  default     = "mongo:4.2"
}

variable "db_cpu" {
  type        = number
  description = "CPU shares allocated to the MongoDB task."
  default     = 1000
}

variable "db_memory" {
  type        = number
  description = "Memory (MB) allocated to the MongoDB task."
  default     = 4096
}

variable "db_health_check_interval" {
  type        = string
  description = "Interval between Consul health checks for the MongoDB service."
  default     = "10s"
}

variable "db_health_check_timeout" {
  type        = string
  description = "Timeout for Consul health checks for the MongoDB service."
  default     = "2s"
}

variable "mongodb_storage_type" {
  type        = string
  description = "MongoDB storage type: host_volume, csi, or ephemeral. Use ephemeral to disable persistent volume wiring."
  default     = "host_volume"
}

variable "mongodb_volume_source" {
  type        = string
  description = "Nomad volume source name for MongoDB persistent storage (host_volume name or CSI volume ID)."
  default     = "openstudio-mongodb"
}

variable "redis_image" {
  type        = string
  description = "The Redis image name and tag."
  default     = "redis:6.2-alpine"
}

variable "redis_cpu" {
  type        = number
  description = "CPU shares allocated to the Redis task."
  default     = 250
}

variable "redis_memory" {
  type        = number
  description = "Memory (MB) allocated to the Redis task."
  default     = 1024
}

variable "redis_storage_type" {
  type        = string
  description = "Redis storage type: host_volume, csi, or ephemeral. Use ephemeral to disable persistent volume wiring."
  default     = "host_volume"
}

variable "redis_volume_source" {
  type        = string
  description = "Nomad volume source name for Redis persistent storage (host_volume name or CSI volume ID)."
  default     = "openstudio-redis"
}

variable "redis_health_check_interval" {
  type        = string
  description = "Interval between Consul health checks for the Redis service."
  default     = "10s"
}

variable "redis_health_check_timeout" {
  type        = string
  description = "Timeout for Consul health checks for the Redis service."
  default     = "2s"
}

variable "nfs_shared_volume_enabled" {
  type        = bool
  description = "When true, a CSI NFS shared volume is declared and mounted in both web and worker task groups."
  default     = false
}

variable "nfs_volume_source" {
  type        = string
  description = "Nomad CSI volume ID for the NFS shared volume used by web and worker task groups."
  default     = "openstudio-nfs"
}

variable "nfs_volume_mount_path" {
  type        = string
  description = "Mount path inside web and worker tasks where the NFS shared volume is attached."
  default     = "/mnt/openstudio"
}

variable "rserve_image" {
  type        = string
  description = "The Rserve image name and tag."
  default     = "nrel/openstudio-rserve:latest"
}

variable "rserve_cpu" {
  type        = number
  description = "CPU shares allocated to the Rserve task."
  default     = 1000
}

variable "rserve_memory" {
  type        = number
  description = "Memory (MB) allocated to the Rserve task."
  default     = 2048
}

variable "rserve_health_check_interval" {
  type        = string
  description = "Interval between Consul health checks for the Rserve service."
  default     = "10s"
}

variable "rserve_health_check_timeout" {
  type        = string
  description = "Timeout for Consul health checks for the Rserve service."
  default     = "2s"
}

variable "enable_consul_connect" {
  type        = bool
  description = "Enable Consul Connect sidecar proxies for mTLS service-to-service communication."
  default     = false
}

# Logging configuration variables
variable "log_driver_type" {
  type        = string
  description = "The logging driver to use for the containers."
  default     = "json-file"
}

variable "log_max_size" {
  type        = string
  description = "The maximum size of log files before rotation."
  default     = "10m"
}

variable "log_max_files" {
  type        = number
  description = "The maximum number of log files to keep."
  default     = 3
}

# Vector configuration variables
variable "enable_vector_collection" {
  type        = bool
  description = "Enable Vector sidecar for log collection."
  default     = true
}

variable "vector_image" {
  type        = string
  description = "The Vector image name and tag."
  default     = "timberio/vector:0.30.0-alpine"
}

# Vault-backed MongoDB secret template variables
variable "enable_vault_mongo_secrets" {
  type        = bool
  description = "Enable dynamic MongoDB credential mapping from Vault into MongoDB task environment variables."
  default     = false
}

variable "vault_mongo_secret_path" {
  type        = string
  description = "Vault secret path for MongoDB credentials (for example: secret/data/openstudio/mongodb)."
  default     = "secret/data/openstudio/mongodb"
}

variable "vault_mongo_username_key" {
  type        = string
  description = "Key in the Vault secret data payload containing the MongoDB username."
  default     = "username"
}

variable "vault_mongo_password_key" {
  type        = string
  description = "Key in the Vault secret data payload containing the MongoDB password."
  default     = "password"
}

# Scheduling helper inputs
variable "db_constraints" {
  type        = any
  description = "Placement constraints for the db group."
  default     = []
}

variable "db_affinities" {
  type        = any
  description = "Placement affinities for the db group."
  default     = []
}

variable "db_spreads" {
  type        = any
  description = "Spread rules for the db group."
  default     = []
}

variable "redis_constraints" {
  type        = any
  description = "Placement constraints for the redis group."
  default     = []
}

variable "redis_affinities" {
  type        = any
  description = "Placement affinities for the redis group."
  default     = []
}

variable "redis_spreads" {
  type        = any
  description = "Spread rules for the redis group."
  default     = []
}

variable "rserve_constraints" {
  type        = any
  description = "Placement constraints for the rserve group."
  default     = []
}

variable "rserve_affinities" {
  type        = any
  description = "Placement affinities for the rserve group."
  default     = []
}

variable "rserve_spreads" {
  type        = any
  description = "Spread rules for the rserve group."
  default     = []
}

# Backup and restore jobs
variable "backup_enabled" {
  type        = bool
  description = "Enable the periodic MongoDB and Redis backup batch job."
  default     = true
}

variable "backup_cron" {
  type        = string
  description = "Cron expression for the periodic backup schedule."
  default     = "0 2 * * * *"
}

variable "backup_prohibit_overlap" {
  type        = bool
  description = "Prevent overlapping backup runs."
  default     = true
}

variable "backup_nfs_host_volume" {
  type        = string
  description = "Nomad host volume name backed by an NFS mount for state backups."
  default     = "openstudio-backups"
}

variable "backup_mount_path" {
  type        = string
  description = "Path inside backup tasks where the NFS host volume is mounted."
  default     = "/backups"
}

variable "backup_subdirectory" {
  type        = string
  description = "Subdirectory name under the backup mount where OpenStudio state backups are written."
  default     = "openstudio-state"
}

variable "backup_retention_days" {
  type        = number
  description = "How many days of backup files to retain."
  default     = 14
}

variable "mongodb_backup_uri" {
  type        = string
  description = "MongoDB URI used by backup and restore jobs."
  default     = "mongodb://openstudio-db.service.consul:27017"
}

variable "redis_backup_host" {
  type        = string
  description = "Redis host used by backup and restore jobs."
  default     = "openstudio-redis.service.consul"
}

variable "redis_backup_port" {
  type        = number
  description = "Redis port used by backup and restore jobs."
  default     = 6379
}

variable "restore_enabled" {
  type        = bool
  description = "Enable the on-demand restore batch job definition."
  default     = true
}

# Docker runtime hardening variables
variable "docker_user" {
  type        = string
  description = "UID:GID to run containers as (non-root)."
  default     = "1000:1000"
}

variable "docker_readonly_rootfs" {
  type        = bool
  description = "Enable Docker read-only root filesystem."
  default     = true
}

variable "docker_cap_drop" {
  type        = list(string)
  description = "Linux capabilities to drop from Docker containers."
  default     = ["ALL"]
}

variable "enable_image_prepull" {
  type        = bool
  description = "When true, renders the system-hooks job that pre-pulls all heavy images on every eligible node before scheduling."
  default     = true
}

variable "prepull_kill_timeout" {
  type        = string
  description = "kill_timeout applied to every task in the image pre-pull system job. Must be >= 10 minutes to allow large image layers to be pulled."
  default     = "600s"
}

variable "poststop_cleanup_image" {
  type        = string
  description = "The image used for poststop cleanup lifecycle tasks."
  default     = "alpine:3.20"
}

variable "poststop_cleanup_paths" {
  type        = list(string)
  description = "Directories removed by poststop cleanup lifecycle tasks when allocations stop."
  default = [
    "/alloc/tmp/analysis",
    "/alloc/tmp/openstudio/analysis",
  ]
}

# Batch verification configuration
variable "enable_batch_verification" {
  type        = bool
  description = "Enable standalone batch connectivity verification job."
  default     = false
}

variable "verification_image" {
  type        = string
  description = "The image used for batch connectivity verification checks."
  default     = "busybox:1.36"
}

variable "verification_targets" {
  type        = list(string)
  description = "Connectivity targets in component=host:port format for batch verification."
  default = [
    "db=openstudio-db.service.consul:27017",
    "redis=openstudio-redis.service.consul:6379",
    "rserve=openstudio-rserve.service.consul:6311",
  ]
}

# Vault KV secrets integration variables (vault_integration_enabled mechanism)
variable "vault_policy" {
  type        = string
  description = "Name of the Vault policy granted to all OpenStudio Server tasks when vault_integration_enabled is true."
  default     = "openstudio-server"
}

variable "vault_kv_mongodb_path" {
  type        = string
  description = "Vault KV v2 path for MongoDB credentials (must contain a 'password' key)."
  default     = "secret/data/openstudio/mongodb"
}

variable "vault_kv_redis_path" {
  type        = string
  description = "Vault KV v2 path for Redis credentials (must contain a 'password' key)."
  default     = "secret/data/openstudio/redis"
}

variable "vault_kv_app_path" {
  type        = string
  description = "Vault KV v2 path for application secrets (must contain a 'secret_key_base' key)."
  default     = "secret/data/openstudio/app"
}

variable "mongo_password" {
  type        = string
  description = "Plaintext MongoDB password used when vault_integration_enabled is false."
  default     = ""
}

variable "redis_password" {
  type        = string
  description = "Plaintext Redis password used when vault_integration_enabled is false."
  default     = ""
}

variable "app_secret_key_base" {
  type        = string
  description = "Plaintext application secret key base used when vault_integration_enabled is false."
  default     = ""
}

# Vault role-based authorization variables
variable "vault_enabled" {
  type        = bool
  description = "Enable Vault role-based authorization blocks in Nomad tasks."
  default     = false
}

variable "vault_default_role" {
  type        = string
  description = "Default Vault role used by tasks when a task-specific role is not set."
  default     = ""
}

variable "vault_db_role" {
  type        = string
  description = "Vault role override for the MongoDB task."
  default     = ""
}

variable "vault_redis_role" {
  type        = string
  description = "Vault role override for the Redis task."
  default     = ""
}

variable "vault_rserve_role" {
  type        = string
  description = "Vault role override for the Rserve task."
  default     = ""
}

variable "vault_vector_role" {
  type        = string
  description = "Vault role override for Vector sidecar tasks."
  default     = ""
}

variable "vault_policies" {
  type        = list(string)
  description = "Additional Vault policies to attach to Nomad-issued Vault tokens."
  default     = []
}

variable "vault_namespace" {
  type        = string
  description = "Vault namespace used for task token requests (Enterprise Vault)."
  default     = ""
}

variable "vault_change_mode" {
  type        = string
  description = "How tasks react to Vault token or secret changes."
  default     = "restart"
}

variable "vault_change_signal" {
  type        = string
  description = "Signal sent to tasks when vault_change_mode is set to signal."
  default     = "SIGHUP"
}

variable "vault_env" {
  type        = bool
  description = "Expose Vault token to tasks as environment variables."
  default     = true
}

# Test job variables (openstudio_test.nomad.tpl)
variable "test_web_port" {
  type        = number
  description = "Port for the HTTP health check against openstudio-web.service.consul."
  default     = 80
}

variable "test_redis_port" {
  type        = number
  description = "Port for the TCP check against openstudio-redis.service.consul."
  default     = 6379
}

variable "test_mongo_port" {
  type        = number
  description = "Port for the TCP check against openstudio-db.service.consul (MongoDB)."
  default     = 27017
}

variable "test_rserve_port" {
  type        = number
  description = "Port for the TCP check against openstudio-rserve.service.consul."
  default     = 6311
}

variable "test_timeout_seconds" {
  type        = number
  description = "Per-check timeout in seconds passed to curl --max-time and nc -w."
  default     = 10
}

variable "test_retry_count" {
  type        = number
  description = "Number of curl retries for the web HTTP health check."
  default     = 3
}

variable "test_curl_image_tag" {
  type        = string
  description = "Tag for the curlimages/curl image used in the web HTTP check task."
  default     = "latest"
}

variable "test_busybox_image_tag" {
  type        = string
  description = "Tag for the busybox image used in TCP check tasks."
  default     = "stable"
}

# Node class / placement variables
variable "compute_node_class" {
  type        = string
  description = "Nomad node class label for CPU-intensive compute nodes. Used by the openstudio_server.compute_node_constraint helper macro."
  default     = "compute"
}

variable "system_node_class" {
  type        = string
  description = "Nomad node class label for infrastructure/system nodes. Used by the openstudio_server.system_node_constraint helper macro."
  default     = "system"
}
