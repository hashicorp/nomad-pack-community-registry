job [[ template "job_name" . ]] {

  datacenters = [[ .rabbitmq.datacenters | toJson ]]
  type        = "service"

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_set"
  }

  group "cluster" {
    count = [[ .rabbitmq.cluster_size ]]

    update {
      max_parallel = 1
    }

    migrate {
      max_parallel     = 1
      health_check     = "checks"
      min_healthy_time = "5s"
      healthy_deadline = "30s"
    }

    network {
      port "amqp" {
        to = 5671
        [[- template "port" .rabbitmq.port_amqp ]]
      }
      port "ui" {
        to     = 15671
        [[- template "port" .rabbitmq.port_ui ]]
      }
      port "discovery" {
        to     = [[ .rabbitmq.port_discovery ]]
        static = [[ .rabbitmq.port_discovery ]]
      }
      port "clustering" {
        to     = [[ .rabbitmq.port_clustering ]]
        static = [[ .rabbitmq.port_clustering ]]
      }
    }

    task "rabbit" {
      driver = "docker"

      [[ if .rabbitmq.vault_enabled -]]
      vault {
        policies    = [[ .rabbitmq.vault_roles | toJson ]]
        change_mode = "restart"
      }
      [[- end ]]

      config {
        image      = "[[ .rabbitmq.image ]]"
        hostname   = "${attr.unique.hostname}"
        ports      = ["amqp", "ui", "discovery", "clustering"]

        volumes = [
          "local/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf",
          "local/enabled_plugins:/etc/rabbitmq/enabled_plugins"
        ]
      }

      env {
        CONSUL_HOST        = "${attr.unique.network.ip-address}"
        CONSUL_SVC_PORT    = "${NOMAD_HOST_PORT_amqp}"
        CONSUL_SVC_TAGS    = "amqp"
        ERL_EPMD_PORT      = "[[ .rabbitmq.port_discovery ]]"
        RABBITMQ_DIST_PORT = "[[ .rabbitmq.port_clustering ]]"
      }

      template {
        data        = [[ template "rabbit_plugins" .rabbitmq ]]
        destination = "local/enabled_plugins"
      }

      template {
        data        = <<EOH
cluster_formation.peer_discovery_backend = rabbit_peer_discovery_consul
cluster_formation.consul.svc_addr_auto = true

listeners.ssl.default = {{ env "NOMAD_PORT_amqp" }}

management.ssl.port       = {{ env "NOMAD_PORT_ui" }}
management.ssl.cacertfile = /secrets/ca.crt
management.ssl.certfile   = /secrets/rabbit.crt
management.ssl.keyfile    = /secrets/rabbit.key

ssl_options.verify               = verify_peer
ssl_options.fail_if_no_peer_cert = true
ssl_options.cacertfile           = /secrets/ca.crt
ssl_options.certfile             = /secrets/rabbit.crt
ssl_options.keyfile              = /secrets/rabbit.key

[[ .rabbitmq.extra_conf ]]
        EOH
        destination = "local/rabbitmq.conf"
      }

      [[ template "pki" .rabbitmq ]]

      [[ template "rabbit_env" .rabbitmq ]]

      [[ template "consul_services" .rabbitmq ]]

    }
  }
}
