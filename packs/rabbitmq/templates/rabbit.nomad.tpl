job [[ template "job_name" . ]] {

  datacenters = [[ var "datacenters" . | toJson ]]
  node_pool   = [[ var "node_pool" . | quote ]]

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_set"
  }

  group "cluster" {
    count = [[ var "cluster_size" . ]]

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
        [[- template "port" var "port_amqp" . ]]
      }
      port "ui" {
        to     = 15671
        [[- template "port" var "port_ui" . ]]
      }
      port "discovery" {
        to     = [[ var "port_discovery" . ]]
        static = [[ var "port_discovery" . ]]
      }
      port "clustering" {
        to     = [[ var "port_clustering" . ]]
        static = [[ var "port_clustering" . ]]
      }
    }

    task "rabbit" {
      driver = "docker"

      [[ if var "vault_enabled" . -]]
      vault {
        policies    = [[ var "vault_roles" . | toJson ]]
        change_mode = "restart"
      }
      [[- end ]]

      config {
        image      = "[[ var "image" . ]]"
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
        ERL_EPMD_PORT      = "[[ var "port_discovery" . ]]"
        RABBITMQ_DIST_PORT = "[[ var "port_clustering" . ]]"
      }

      template {
        data        = [[ template "rabbit_plugins" . ]]
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

[[ var "extra_conf" . ]]
        EOH
        destination = "local/rabbitmq.conf"
      }

      [[ template "pki" . ]]

      [[ template "rabbit_env" . ]]

      [[ template "consul_services" . ]]

    }
  }
}
