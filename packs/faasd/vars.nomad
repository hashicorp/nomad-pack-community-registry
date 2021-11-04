docker_faasd_env_vars = {
  "java_opts": "-Dhudson.model.DownloadService.noSignatureCheck=true",
}
volume_name = "faasd-volume"
register_consul_service = true
