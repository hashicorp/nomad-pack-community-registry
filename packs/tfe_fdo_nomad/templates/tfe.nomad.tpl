# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job [[ var "job_name" . | quote ]] {
  datacenters = [[ var "datacenters" .  | toStringList ]]
  namespace   = [[ var "tfe_namespace" . | quote ]]
  type        = "service"

  group "tfe-group" {
    count = [[ var "tfe_group_count" . ]]

    restart {
      attempts = 3
      delay    = "60s"
      interval = "10m"
      mode     = "fail"
    }

    update {
      min_healthy_time  = "30s"
      healthy_deadline  = "12m"
      progress_deadline = "15m"
      health_check      = "checks"
    }


    network {
      port "tfe" {
        static = [[ var "tfe_port" . ]]
      }
      port "http" {
        static = [[ var "tfe_http_port" . ]]
      }
      port "vault" {
        static = [[ var "tfe_vault_cluster_port" . ]]
      }
    }

    service {
      name     = [[ var "tfe_service_name" . | quote ]]
      port     = "tfe"
      provider = [[ var "tfe_service_discovery_provider" . | quote ]]

      check {
        type     = "http"
        port     = "http"
        path     = "/_health_check"
        interval = [[ var "health_check_interval" . | quote ]]
        timeout  = [[ var "health_check_timeout" . | quote ]]
      }
    }

    task "tfe-task" {
      driver = "docker"

      identity {
         env = true
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/key.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ var "job_name" . ]]" -}}
  {{ base64Decode .key.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/cert.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ var "job_name" . ]]" -}}
  {{ base64Decode .cert.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/bundle.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ var "job_name" . ]]" -}}
  {{ base64Decode .bundle.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/secrets.env"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ var "job_name" . ]]" -}}
TFE_LICENSE                             = {{ .tfe_license }}
TFE_DATABASE_PASSWORD                   = {{ .db_password }}
TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY = {{ .s3_secret_key }}
TFE_REDIS_PASSWORD                      = {{ .redis_password }}
TFE_ENCRYPTION_PASSWORD                 = {{ .tfe_encryption_password }}
TFE_IMAGE_REGISTRY_PASSWORD             = {{ .tfe_image_registry_password }}
{{- end -}}
EOF
      }

      config {
         image = [[ var "tfe_image" . | quote ]]
         auth {
            username = [[ var "tfe_image_registry_username" . | quote ]]
            password       = "${TFE_IMAGE_REGISTRY_PASSWORD}"
            server_address = [[ var "tfe_image_server_address" . | quote ]]
         }
         ports = ["tfe", "http", "vault"]
  
      }

      env {
        
        TFE_RUN_PIPELINE_DRIVER = "nomad"
        TFE_DISK_CACHE_VOLUME_NAME                 = "${NOMAD_TASK_DIR}/terraform-enterprise-cache"

        TFE_OPERATIONAL_MODE = "active-active"

        TFE_RUN_PIPELINE_NOMAD_AGENT_JOB_ID = [[ var "tfe_agent_job_id" . | quote ]]

        TFE_DATABASE_USER = [[ var "tfe_database_user" . | quote ]]
        TFE_DATABASE_HOST       = [[ var "tfe_database_host" . | quote ]]
        TFE_DATABASE_NAME       = [[ var "tfe_database_name" . | quote ]]
        TFE_DATABASE_PARAMETERS = [[ var "tfe_database_parameters" . | quote ]]

        TFE_OBJECT_STORAGE_TYPE = [[ var "tfe_object_storage_type" . | quote ]]
        TFE_OBJECT_STORAGE_S3_BUCKET               = [[ var "tfe_object_storage_s3_bucket" . | quote ]]
        TFE_OBJECT_STORAGE_S3_REGION               = [[ var "tfe_object_storage_s3_region" . | quote ]]
        TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE = [[ var "tfe_object_storage_s3_use_instance_profile" . | quote ]]
        TFE_OBJECT_STORAGE_S3_ENDPOINT             = [[ var "tfe_object_storage_s3_endpoint" . | quote ]]
        TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID = [[ var "tfe_object_storage_s3_access_key_id" . | quote ]]

        TFE_REDIS_HOST     = [[ var "tfe_redis_host" . | quote ]]
        TFE_REDIS_USER     = [[ var "tfe_redis_user" . | quote ]]
        TFE_REDIS_USE_TLS  = [[ var "tfe_redis_use_tls" . | quote ]]
        TFE_REDIS_USE_AUTH = [[ var "tfe_redis_use_auth" . | quote ]]

        TFE_HOSTNAME = [[ var "tfe_hostname" . | quote ]]
        
        TFE_TLS_CERT_FILE      = "${NOMAD_SECRETS_DIR}/cert.pem"
        TFE_TLS_KEY_FILE       = "${NOMAD_SECRETS_DIR}/key.pem"
        TFE_TLS_CA_BUNDLE_FILE = "${NOMAD_SECRETS_DIR}/bundle.pem"

        TFE_IACT_SUBNETS    = [[ var "tfe_iact_subnets" . | quote ]]
        TFE_IACT_TIME_LIMIT = [[ var "tfe_iact_time_limit" . | quote ]]

        # Disabling mlock is recommended for TFE installations on Nomad. 
        # Here is a link to the docuementation for more info https://developer.hashicorp.com/vault/docs/configuration#disable_mlock
        TFE_VAULT_DISABLE_MLOCK   = [[ var "tfe_vault_disable_mlock" . | quote ]]
        TFE_VAULT_CLUSTER_ADDRESS = [[ var "tfe_vault_cluster_address" . | quote ]]
        TFE_HTTP_PORT             = [[ var "tfe_http_port" . ]]
        TFE_HTTPS_PORT            = [[ var "tfe_port" . ]]
      }

      resources {
        cpu    = [[ var "tfe_resource_cpu" . ]]  # MHz
        memory = [[ var "tfe_resource_memory" . ]]  # MB
      }
    }
  }
}
