job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  type = "system"

  group "nodes" {

    restart {
      attempts = [[ var "job_restart_config.attempts" . ]]
      delay    = [[ var "job_restart_config.delay" . | quote ]]
      mode     = [[ var "job_restart_config.mode" . | quote ]]
      interval = [[ var "job_restart_config.interval" . | quote ]]
    }
    
    [[ template "constraints" var "constraints" . ]]

    [[- template "vault_config" . ]]

    task "cinder-node" {
      driver = "docker"
      template {
        data        = <<EOT
[[ $config := var "cloud_conf_file" . ]][[ fileContents $config ]]
        EOT
        destination = "secrets/cloud.conf"
        change_mode = "restart"
      }
      config {
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:[[ var "version_tag" . ]]"

        mount {
            type     = "bind"
            target   = "/etc/config/cloud.conf"
            source   = "./secrets/cloud.conf"
            readonly = false
            bind_options {
              propagation = "rshared"
            }
          }
        args = [
          "/bin/cinder-csi-plugin",
          "-v=[[ var "cinder_log_level" . ]]",
          "--endpoint=unix:///csi/csi.sock",
          "--cloud-config=/etc/config/cloud.conf",
        ]
        privileged = true
      }

      csi_plugin {
        id        = "[[ var "csi_plugin_id" . ]]"
        type      = "node"
        mount_dir = "/csi"
      }
    }
    task "cinder-controller" {
      driver = "docker"
      template {
        data        = <<EOT
[[ $config := var "cloud_conf_file" . ]][[ fileContents $config ]]
        EOT
        destination = "secrets/cloud.conf"
        change_mode = "restart"
      }
      config {
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:[[ var "version_tag" . ]]"
        mount {
            type     = "bind"
            target   = "/etc/config/cloud.conf"
            source   = "./secrets/cloud.conf"
            readonly = false
            bind_options {
              propagation = "rshared"
            }
          }

        args = [
          "/bin/cinder-csi-plugin",
          "-v=[[ var "cinder_log_level" . ]]",
          "--endpoint=unix:///csi/csi.sock",
          "--cloud-config=/etc/config/cloud.conf",
        ]
      }

      csi_plugin {
        id        = "[[ var "csi_plugin_id" . ]]"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
