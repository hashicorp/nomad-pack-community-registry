# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job [[ .tfe_fdo_nomad.job_name | quote ]] {
  datacenters = [[ .tfe_fdo_nomad.datacenters  | toStringList ]]
  namespace   = [[ .tfe_fdo_nomad.tfe_namespace | quote ]]
  type        = "service"

  group "tfe-group" {
    count = [[ .tfe_fdo_nomad.tfe_group_count ]]
    
    spread {
      attribute = "${node.unique.id}"
    }

    restart {
      attempts = 3
      delay    = "60s"
      interval = "10m"
      mode     = "fail"
    }

    update {
      max_parallel      = 1
      min_healthy_time  = "30s"
      healthy_deadline  = "12m"
      progress_deadline = "15m"
      health_check      = "checks"
    }


    network {
      port "tfe" {
        static = [[ .tfe_fdo_nomad.tfe_port ]]
      }
      port "http" {
        static = [[ .tfe_fdo_nomad.tfe_http_port ]]
      }
      port "vault" {
        static = [[ .tfe_fdo_nomad.tfe_vault_cluster_port ]]
      }
    }

    service {
      name     = [[ .tfe_fdo_nomad.tfe_service_name | quote ]]
      port     = "tfe"
      provider = [[ .tfe_fdo_nomad.tfe_service_discovery_provider | quote ]]

      check {
        type     = "http"
        port     = "http"
        path     = "/_health_check"
        interval = [[ .tfe_fdo_nomad.health_check_interval | quote ]]
        timeout  = [[ .tfe_fdo_nomad.health_check_timeout | quote ]]
      }
    }

    task "tfe-task" {
      driver = "docker"

      identity {
         env = true
      }

       template {
        destination = "/secrets/key.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .key.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "/secrets/cert.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .cert.Value }}
{{- end -}}
EOF
      }
      template {
        destination = "/secrets/bundle.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .bundle.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "/secrets/nomad_ca_cert.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .nomad_ca.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "/secrets/nomad_cert.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .nomad_cert.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "/secrets/nomad_cert_key.pem"
        change_mode = "restart"
        splay       = "60s"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
  {{ base64Decode .nomad_cert_key.Value }}
{{- end -}}
EOF
      }

      template {
        destination = "/secrets/secrets.env"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .tfe_fdo_nomad.job_name ]]" -}}
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
         image = [[ .tfe_fdo_nomad.tfe_image | quote ]]
         auth {
            # User Input is mandatory.
            username = [[ .tfe_fdo_nomad.tfe_image_registry_username | quote ]]
            # User Input is mandatory.
            password       = "${TFE_IMAGE_REGISTRY_PASSWORD}"
            server_address = [[ .tfe_fdo_nomad.tfe_image_server_address | quote ]]
         }
         ports = ["tfe", "http", "vault"]

         volumes = [
          "secrets:[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]",
        ]
  
      }

      env {
        
        TFE_RUN_PIPELINE_DRIVER = "nomad"
        # User Input is mandatory. 
        TFE_RUN_PIPELINE_NOMAD_ADDRESS             = [[ .tfe_fdo_nomad.tfe_run_pipeline_nomad_address | quote ]]
        TFE_RUN_PIPELINE_NOMAD_TLS_CONFIG_INSECURE = [[ .tfe_fdo_nomad.tfe_run_pipeline_nomad_tls_config_insecure | quote ]]
        TFE_RUN_PIPELINE_NOMAD_TLS_CONFIG_CA_CERT = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/nomad_ca_cert.pem"
        TFE_RUN_PIPELINE_NOMAD_TLS_CONFIG_CLIENT_CERT = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/nomad_cert.pem"
        TFE_RUN_PIPELINE_NOMAD_TLS_CONFIG_CLIENT_KEY = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/nomad_cert_key.pem"
        TFE_DISK_CACHE_VOLUME_NAME                 = "${NOMAD_TASK_DIR}/terraform-enterprise-cache-1"

        TFE_OPERATIONAL_MODE = "active-active"

        TFE_DATABASE_USER = [[ .tfe_fdo_nomad.tfe_database_user | quote ]]
        # User Input is mandatory. 
        TFE_DATABASE_HOST       = [[ .tfe_fdo_nomad.tfe_database_host | quote ]]
        TFE_DATABASE_NAME       = [[ .tfe_fdo_nomad.tfe_database_name | quote ]]
        TFE_DATABASE_PARAMETERS = [[ .tfe_fdo_nomad.tfe_database_parameters | quote ]]

        TFE_OBJECT_STORAGE_TYPE = [[ .tfe_fdo_nomad.tfe_object_storage_type | quote ]]
        TFE_OBJECT_STORAGE_S3_BUCKET               = [[ .tfe_fdo_nomad.tfe_object_storage_s3_bucket | quote ]]
        TFE_OBJECT_STORAGE_S3_REGION               = [[ .tfe_fdo_nomad.tfe_object_storage_s3_region | quote ]]
        TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE = [[ .tfe_fdo_nomad.tfe_object_storage_s3_use_instance_profile ]]
        TFE_OBJECT_STORAGE_S3_ENDPOINT             = [[ .tfe_fdo_nomad.tfe_object_storage_s3_endpoint | quote ]]
        # User Input is mandatory. 
        TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID = [[ .tfe_fdo_nomad.tfe_object_storage_s3_access_key_id | quote ]]

        # User Input is mandatory. 
        TFE_REDIS_HOST     = [[ .tfe_fdo_nomad.tfe_redis_host | quote ]]
        TFE_REDIS_USER     = [[ .tfe_fdo_nomad.tfe_redis_user | quote ]]
        TFE_REDIS_USE_TLS  = [[ .tfe_fdo_nomad.tfe_redis_use_tls | quote ]]
        TFE_REDIS_USE_AUTH = [[ .tfe_fdo_nomad.tfe_redis_use_auth | quote ]]

        # User Input is mandatory. 
        TFE_HOSTNAME = [[ .tfe_fdo_nomad.tfe_hostname | quote ]]
        
        TFE_TLS_CERT_FILE      = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/cert.pem"
        TFE_TLS_KEY_FILE       = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/key.pem"
        TFE_TLS_CA_BUNDLE_FILE = "[[ .tfe_fdo_nomad.tfe_tls_cert_mount_path ]]/bundle.pem"

        TFE_IACT_SUBNETS    = [[ .tfe_fdo_nomad.tfe_iact_subnets | quote ]]
        TFE_IACT_TIME_LIMIT = [[ .tfe_fdo_nomad.tfe_iact_time_limit | quote ]]

        # Disabling mlock is recommended for TFE installations on Nomad. 
        # Here is a link to the docuementation for more info https://developer.hashicorp.com/vault/docs/configuration#disable_mlock
        TFE_VAULT_DISABLE_MLOCK   = [[ .tfe_fdo_nomad.tfe_vault_disable_mlock | quote ]]
        TFE_VAULT_CLUSTER_ADDRESS = [[ .tfe_fdo_nomad.tfe_vault_cluster_address | quote ]]
        TFE_HTTP_PORT             = [[ .tfe_fdo_nomad.tfe_http_port ]]
        TFE_HTTPS_PORT            = [[ .tfe_fdo_nomad.tfe_port ]]
      }

      resources {
        cpu    = [[ .tfe_fdo_nomad.tfe_resource_cpu ]]  # MHz
        memory = [[ .tfe_fdo_nomad.tfe_resource_memory ]]  # MB
      }
    }
  }
}
