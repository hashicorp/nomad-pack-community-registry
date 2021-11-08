job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .ctfd.datacenters | toPrettyJson ]]
  [[- if .ctfd.namespace ]]
  namespace   = [[ .ctfd.namespace | quote ]]
  [[- end ]]
  type = "service"

  constraint {
    attribute = "${attr.driver.docker.volumes.enabled}",
    value     = "true",
  }

  group [[ template "job_name" . ]] {
    count = 1

    network {
      port "ctfd" {
        [[- if .ctfd.ctfd_port ]]
        static = [[- .ctfd.ctfd_port ]]
        [[- end ]]
        to = 8000
      }
      port "mariadb" {
        to = 3306
      }
      port "redis" {
        to = 6379
      }
    }

    [[- if .ctfd.register_consul_service ]]
    service {
      name = "[[ .ctfd.consul_service_name ]]"
      [[- if ne (len .ctfd.consul_service_tags) 0 ]]
      tags = [[ .ctfd.consul_service_tags | toPrettyJson ]]
      [[- end ]]
      port = "http"

      check {
        type     = "http"
        port     = "ctfd"
        path     = "/"
        interval = "10s"
        timeout  = "5s"
      }
    }
    [[- end ]]

    task "ctfd" {
      driver = "docker"

      service {
        name = "[[ .ctfd.job_name ]]-ctfd"
        port = "ctfd"

        tags = [[ .ctfd.consul_service_tags | toPrettyJson ]]

        check {
          type = "http"
          port = "ctfd"
          path = "/"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }

      restart {
        attempts = 3
        interval = "15m"
        delay = "30s"
        mode = "fail"
      }

      env {
        UPLOAD_FOLDER = "/var/uploads"
        DATABASE_URL = "mysql+pymysql://ctfd:[[ .ctfd.mariadb_ctfd_password ]]@[[ .ctfd.job_name ]]-db.service.consul:${NOMAD_HOST_PORT_mariadb}/ctfd"
        REDIS_URL = "redis://[[ .ctfd.job_name ]]-cache.service.consul:${NOMAD_HOST_PORT_redis}"
        WORKERS = "1"
        LOG_FOLDER = "${NOMAD_ALLOC_DIR}/logs/ctfd"
        ACCESS_LOG = "${NOMAD_ALLOC_DIR}/logs/gunicorn.access"
        ERROR_LOG = "${NOMAD_ALLOC_DIR}/logs/gunicorn.error"
        [[- if .ctfd.ctfd_expect_reverse_proxy ]]
        REVERSE_PROXY = "true"
        [[- end]]
        FLASK_ENV = "production"
      }

      config {
        image = "[[ .ctfd.ctfd_image_name ]]:[[ .ctfd.ctfd_image_tag ]]"
        ports = ["ctfd"]
      }

      resources {
        cpu = [[ .ctfd.ctfd_resources.cpu ]]
        memory = [[ .ctfd.ctfd_resources.memory ]]
      }

      volume_mount {
        volume = "[[ .ctfd.uploads_volume_name ]]"
        destination = "/var/uploads"
      }
    }

    task "db" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = true
      }

      service {
        name = "[[ .ctfd.job_name ]]-db"
        port = "mariadb"

        tags = [[ .ctfd.consul_service_tags | toPrettyJson ]]

        check {
          type = "tcp"
          port = "mariadb"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }

      env {
        MYSQL_ROOT_PASSWORD = "[[ .ctfd.mariadb_root_password ]]"
        MYSQL_USER = "ctfd"
        MYSQL_PASSWORD = "[[ .ctfd.mariadb_ctfd_password ]]"
        MYSQL_DATABASE = "ctfd"
      }

      config {
        image = "[[ .ctfd.mariadb_image_name ]]:[[ .ctfd.mariadb_image_tag ]]"
        command = "mysqld"
        args = [
          "--character-set-server=utf8mb4",
          "--collation-server=utf8mb4_unicode_ci",
          "--wait_timeout=28800",
          "--log-warnings=0"
        ]
        ports = ["mariadb"]
      }

      resources {
        cpu = [[ .ctfd.mariadb_resources.cpu ]]
        memory = [[ .ctfd.mariadb_resources.memory ]]
      }

      volume_mount {
        volume = "[[ .ctfd.mariadb_volume_name ]]"
        destination = "/var/lib/mysql"
      }
    }

    task "cache" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = true
      }

      service {
        name = "[[ .ctfd.job_name ]]-cache"
        port = "redis"

        tags = [[ .ctfd.consul_service_tags | toPrettyJson ]]

        check {
          type = "tcp"
          port = "redis"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit = 3
            grace = "30s"
          }
        }
      }

      config {
        image = "[[ .ctfd.redis_image_name ]]:[[ .ctfd.redis_image_tag ]]"
        ports = ["redis"]
      }

      resources {
        cpu = [[ .ctfd.redis_resources.cpu ]]
        memory = [[ .ctfd.redis_resources.memory ]]
      }

      volume_mount {
        volume = "[[ .ctfd.redis_volume_name ]]"
        destination = "/data"
      }
    }

    volume "[[ .ctfd.uploads_volume_name ]]" {
      type      = "[[ .ctfd.uploads_volume_type ]]"
      read_only = false
      source    = "[[ .ctfd.uploads_volume_name ]]"
    }

    volume "[[ .ctfd.mariadb_volume_name ]]" {
      type      = "[[ .ctfd.mariadb_volume_type ]]"
      read_only = false
      source    = "[[ .ctfd.mariadb_volume_name ]]"
    }

    volume "[[ .ctfd.redis_volume_name ]]" {
      type      = "[[ .ctfd.redis_volume_type ]]"
      read_only = false
      source    = "[[ .ctfd.redis_volume_name ]]"
    }
  }
}
