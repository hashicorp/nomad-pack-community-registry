[[ if var "backup_enabled" . ]]
job "[[ var "job_name" . ]]-state-backup" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "batch"

  periodic {
    cron             = "[[ var "backup_cron" . ]]"
    prohibit_overlap = [[ var "backup_prohibit_overlap" . ]]
  }

  group "backup" {
    count = 1

    volume "state_backups" {
      type      = "host"
      source    = "[[ var "backup_nfs_host_volume" . ]]"
      read_only = false
    }

    task "mongo-backup" {
      driver = "docker"

      config {
        image      = "[[ var "db_image" . ]]"
        entrypoint = ["/bin/sh", "-ec"]
        args = [<<EOH
ts="$(date -u +%Y%m%dT%H%M%SZ)"
base_dir="${BACKUP_MOUNT_PATH}/${BACKUP_SUBDIRECTORY}"
mkdir -p "${base_dir}"
mongo_file="${base_dir}/mongo-${ts}.archive.gz"
mongodump --uri="${MONGODB_URI}" --gzip --archive="${mongo_file}"
find "${base_dir}" -name 'mongo-*.archive.gz' -type f -mtime +"${BACKUP_RETENTION_DAYS}" -delete
echo "MongoDB backup complete: ${mongo_file}"
EOH
        ]
      }

      env {
        MONGODB_URI           = "[[ var "mongodb_backup_uri" . ]]"
        BACKUP_MOUNT_PATH     = "[[ var "backup_mount_path" . ]]"
        BACKUP_SUBDIRECTORY   = "[[ var "backup_subdirectory" . ]]"
        BACKUP_RETENTION_DAYS = "[[ var "backup_retention_days" . ]]"
      }

      volume_mount {
        volume      = "state_backups"
        destination = "[[ var "backup_mount_path" . ]]"
        read_only   = false
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }

    task "redis-backup" {
      driver = "docker"

      config {
        image      = "[[ var "redis_image" . ]]"
        entrypoint = ["/bin/sh", "-ec"]
        args = [<<EOH
set -eu
ts="$(date -u +%Y%m%dT%H%M%SZ)"
base_dir="${BACKUP_MOUNT_PATH}/${BACKUP_SUBDIRECTORY}"
mkdir -p "${base_dir}"
redis_file="${base_dir}/redis-${ts}.dump.tsv"
redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" --scan | while IFS= read -r key; do
  key_b64="$(printf "%s" "${key}" | base64 | tr -d '\n')"
  dump_b64="$(redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" --raw DUMP "${key}" | base64 | tr -d '\n')"
  ttl_ms="$(redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" --raw PTTL "${key}")"
  printf "%s\t%s\t%s\n" "${key_b64}" "${dump_b64}" "${ttl_ms}"
done > "${redis_file}"
find "${base_dir}" -name 'redis-*.dump.tsv' -type f -mtime +"${BACKUP_RETENTION_DAYS}" -delete
echo "Redis backup complete: ${redis_file}"
EOH
        ]
      }

      env {
        REDIS_HOST            = "[[ var "redis_backup_host" . ]]"
        REDIS_PORT            = "[[ var "redis_backup_port" . ]]"
        BACKUP_MOUNT_PATH     = "[[ var "backup_mount_path" . ]]"
        BACKUP_SUBDIRECTORY   = "[[ var "backup_subdirectory" . ]]"
        BACKUP_RETENTION_DAYS = "[[ var "backup_retention_days" . ]]"
      }

      volume_mount {
        volume      = "state_backups"
        destination = "[[ var "backup_mount_path" . ]]"
        read_only   = false
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
[[ end ]]
