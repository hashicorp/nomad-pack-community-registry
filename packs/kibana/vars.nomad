docker_kibana_env_vars = {
  "server_name": "kibana.example.org",
  "server_host": "0.0.0.0",
  "monitoring_enabled": "false",
  "monitoring_ui_container_elasticsearch_enabled": "false",
  "telemetry_enabled" = "false",
  "status_allowanonymous" = "true",
  "xpack_security_enabled" = "false",
}
config_volume_name = "kibana_config"
kibana_keystore_name = "keystore"
register_consul_service = true
