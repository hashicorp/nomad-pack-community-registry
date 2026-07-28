job "[[ var "job_name" . ]]-test" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "batch"

  parameterized {
    meta_optional = ["TEST_TIMEOUT"]
  }

  reschedule {
    attempts = 0
  }

  group "health-checks" {
    count = 1

    restart {
      attempts = 0
      mode     = "fail"
    }

    task "web-http-check" {
      driver = "docker"

      config {
        image   = "curlimages/curl:[[ var "test_curl_image_tag" . ]]"
        command = "sh"
        args = [
          "-c",
          "curl --silent --fail --max-time [[ var "test_timeout_seconds" . ]] --retry [[ var "test_retry_count" . ]] http://openstudio-web.service.consul:[[ var "test_web_port" . ]]/ && echo 'web-http-check: PASS' || (echo 'web-http-check: FAIL'; exit 1)",
        ]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }

    task "redis-tcp-check" {
      driver = "docker"

      config {
        image   = "busybox:[[ var "test_busybox_image_tag" . ]]"
        command = "sh"
        args = [
          "-c",
          "nc -z -w [[ var "test_timeout_seconds" . ]] openstudio-redis.service.consul [[ var "test_redis_port" . ]] && echo 'redis-tcp-check: PASS' || (echo 'redis-tcp-check: FAIL'; exit 1)",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "mongo-tcp-check" {
      driver = "docker"

      config {
        image   = "busybox:[[ var "test_busybox_image_tag" . ]]"
        command = "sh"
        args = [
          "-c",
          "nc -z -w [[ var "test_timeout_seconds" . ]] openstudio-db.service.consul [[ var "test_mongo_port" . ]] && echo 'mongo-tcp-check: PASS' || (echo 'mongo-tcp-check: FAIL'; exit 1)",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "rserve-tcp-check" {
      driver = "docker"

      config {
        image   = "busybox:[[ var "test_busybox_image_tag" . ]]"
        command = "sh"
        args = [
          "-c",
          "nc -z -w [[ var "test_timeout_seconds" . ]] openstudio-rserve.service.consul [[ var "test_rserve_port" . ]] && echo 'rserve-tcp-check: PASS' || (echo 'rserve-tcp-check: FAIL'; exit 1)",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
