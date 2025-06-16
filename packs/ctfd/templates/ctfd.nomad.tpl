job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toPrettyJson ]]
  [[- if var "namespace" . ]]
  namespace   = [[ var "namespace" . | quote ]]
  [[- end ]]
  type = "service"

  constraint {
    attribute = "${attr.driver.docker.volumes.enabled}"
    value     = "true"
  }

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_set"
  }

  group [[ template "job_name" . ]] {
    count = 1

    network {
      port "ctfd" {
        [[- if var "ctfd_port" . ]]
        static = [[- var "ctfd_port" . ]]
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

    [[- if var "register_consul_service" . ]]
    service {
      name = "[[ var "consul_service_name" . ]]"
      [[- if ne (len var "consul_service_tags" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toPrettyJson ]]
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
        name = "[[ var "job_name" . ]]-ctfd"
        port = "ctfd"

        tags = [[ var "consul_service_tags" . | toPrettyJson ]]

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
        DATABASE_URL = "mysql+pymysql://ctfd:[[ var "mariadb_ctfd_password" . ]]@[[ var "job_name" . ]]-db.service.consul:${NOMAD_HOST_PORT_mariadb}/ctfd"
        REDIS_URL = "redis://[[ var "job_name" . ]]-cache.service.consul:${NOMAD_HOST_PORT_redis}"
        WORKERS = "1"
        LOG_FOLDER = "${NOMAD_ALLOC_DIR}/logs/ctfd"
        ACCESS_LOG = "${NOMAD_ALLOC_DIR}/logs/gunicorn.access"
        ERROR_LOG = "${NOMAD_ALLOC_DIR}/logs/gunicorn.error"
        [[- if var "ctfd_expect_reverse_proxy" . ]]
        REVERSE_PROXY = "true"
        [[- end]]
        FLASK_ENV = "production"
      }

      config {
        image = "[[ var "ctfd_image_name" . ]]:[[ var "ctfd_image_tag" . ]]"
        ports = ["ctfd"]
      }

      resources {
        cpu = [[ var "ctfd_resources.cpu" . ]]
        memory = [[ var "ctfd_resources.memory" . ]]
      }

      volume_mount {
        volume = "[[ var "uploads_volume_name" . ]]"
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
        name = "[[ var "job_name" . ]]-db"
        port = "mariadb"

        tags = [[ var "consul_service_tags" . | toPrettyJson ]]

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
        MYSQL_ROOT_PASSWORD = "[[ var "mariadb_root_password" . ]]"
        MYSQL_USER = "ctfd"
        MYSQL_PASSWORD = "[[ var "mariadb_ctfd_password" . ]]"
        MYSQL_DATABASE = "ctfd"
      }

      config {
        image = "[[ var "mariadb_image_name" . ]]:[[ var "mariadb_image_tag" . ]]"
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
        cpu = [[ var "mariadb_resources.cpu" . ]]
        memory = [[ var "mariadb_resources.memory" . ]]
      }

      volume_mount {
        volume = "[[ var "mariadb_volume_name" . ]]"
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
        name = "[[ var "job_name" . ]]-cache"
        port = "redis"

        tags = [[ var "consul_service_tags" . | toPrettyJson ]]

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
        image = "[[ var "redis_image_name" . ]]:[[ var "redis_image_tag" . ]]"
        ports = ["redis"]
      }

      resources {
        cpu = [[ var "redis_resources.cpu" . ]]
        memory = [[ var "redis_resources.memory" . ]]
      }

      volume_mount {
        volume = "[[ var "redis_volume_name" . ]]"
        destination = "/data"
      }
    }

    volume "[[ var "uploads_volume_name" . ]]" {
      type      = "[[ var "uploads_volume_type" . ]]"
      read_only = false
      source    = "[[ var "uploads_volume_name" . ]]"
    }

    volume "[[ var "mariadb_volume_name" . ]]" {
      type      = "[[ var "mariadb_volume_type" . ]]"
      read_only = false
      source    = "[[ var "mariadb_volume_name" . ]]"
    }

    volume "[[ var "redis_volume_name" . ]]" {
      type      = "[[ var "redis_volume_type" . ]]"
      read_only = false
      source    = "[[ var "redis_volume_name" . ]]"
    }
  }
}
