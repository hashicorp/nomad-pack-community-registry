[[ if var "restore_enabled" . ]]
job "[[ var "job_name" . ]]-state-restore" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "batch"

  parameterized {
    meta_required = ["MONGO_BACKUP_FILE", "REDIS_BACKUP_FILE"]
  }

  group "restore" {
    count = 1

    volume "state_backups" {
      type      = "host"
      source    = "[[ var "backup_nfs_host_volume" . ]]"
      read_only = true
    }

    task "mongo-restore" {
      driver = "docker"

      config {
        image      = "[[ var "db_image" . ]]"
        entrypoint = ["/bin/sh", "-ec"]
        args = [<<EOH
mongo_file="${BACKUP_MOUNT_PATH}/${BACKUP_SUBDIRECTORY}/${NOMAD_META_MONGO_BACKUP_FILE}"
test -f "${mongo_file}"
mongorestore --uri="${MONGODB_URI}" --gzip --archive="${mongo_file}" --drop
echo "MongoDB restore complete: ${mongo_file}"
EOH
        ]
      }

      env {
        MONGODB_URI         = "[[ var "mongodb_backup_uri" . ]]"
        BACKUP_MOUNT_PATH   = "[[ var "backup_mount_path" . ]]"
        BACKUP_SUBDIRECTORY = "[[ var "backup_subdirectory" . ]]"
      }

      volume_mount {
        volume      = "state_backups"
        destination = "[[ var "backup_mount_path" . ]]"
        read_only   = true
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }

    task "redis-restore" {
      driver = "docker"

      config {
        image      = "[[ var "redis_image" . ]]"
        entrypoint = ["/bin/sh", "-ec"]
        args = [<<EOH
set -eu
redis_file="${BACKUP_MOUNT_PATH}/${BACKUP_SUBDIRECTORY}/${NOMAD_META_REDIS_BACKUP_FILE}"
test -f "${redis_file}"
redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" FLUSHALL
while IFS="$(printf '\t')" read -r key_b64 dump_b64 ttl_ms; do
  key="$(printf "%s" "${key_b64}" | base64 -d)"
  if [ "${ttl_ms}" = "-1" ] || [ "${ttl_ms}" = "-2" ]; then
    ttl_ms=0
  fi
  printf "%s" "${dump_b64}" | base64 -d | redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" -x RESTORE "${key}" "${ttl_ms}" REPLACE
done < "${redis_file}"
echo "Redis restore complete: ${redis_file}"
EOH
        ]
      }

      env {
        REDIS_HOST          = "[[ var "redis_backup_host" . ]]"
        REDIS_PORT          = "[[ var "redis_backup_port" . ]]"
        BACKUP_MOUNT_PATH   = "[[ var "backup_mount_path" . ]]"
        BACKUP_SUBDIRECTORY = "[[ var "backup_subdirectory" . ]]"
      }

      volume_mount {
        volume      = "state_backups"
        destination = "[[ var "backup_mount_path" . ]]"
        read_only   = true
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
[[ end ]]
