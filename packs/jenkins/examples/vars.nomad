# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

docker_jenkins_env_vars = {
  "java_opts": "-Dhudson.model.DownloadService.noSignatureCheck=true",
}
volume_name = "jenkins-volume"
register_consul_service = true
