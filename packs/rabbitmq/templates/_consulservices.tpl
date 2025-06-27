[[- define "consul_services" -]]
      service {
        name = "rabbitmq"
        port = "amqp"
        tags = [[ var "consul_service_amqp_tags" . | toJson ]]
      }

      service {
        name = "rabbitmq"
        port = "ui"
        tags = [[ var "consul_service_management_tags" . | toJson ]]
      }
[[- end -]]
