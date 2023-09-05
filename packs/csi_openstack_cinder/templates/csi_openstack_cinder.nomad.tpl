job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .csi_openstack_cinder.datacenters | toStringList ]]
  node_pool = [[ .csi_openstack_cinder.node_pool | quote ]]
  type = "system"

  group "nodes" {

    restart {
      attempts = [[ .csi_openstack_cinder.job_restart_config.attempts ]]
      delay    = [[ .csi_openstack_cinder.job_restart_config.delay | quote ]]
      mode     = [[ .csi_openstack_cinder.job_restart_config.mode | quote ]]
      interval = [[ .csi_openstack_cinder.job_restart_config.interval | quote ]]
    }
    
    [[ template "constraints" .csi_openstack_cinder.constraints ]]

    [[- template "vault_config" .csi_openstack_cinder ]]

    task "cinder-node" {
      driver = "docker"
      template {
        data        = <<EOT
[[ $config := .csi_openstack_cinder.cloud_conf_file ]][[ fileContents $config ]]
        EOT
        destination = "secrets/cloud.conf"
        change_mode = "restart"
      }
      config {
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:[[ .csi_openstack_cinder.version_tag ]]"

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
          "-v=[[ .csi_openstack_cinder.cinder_log_level ]]",
          "--endpoint=unix:///csi/csi.sock",
          "--cloud-config=/etc/config/cloud.conf",
        ]
        privileged = true
      }

      csi_plugin {
        id        = "[[ .csi_openstack_cinder.csi_plugin_id ]]"
        type      = "node"
        mount_dir = "/csi"
      }
    }
    task "cinder-controller" {
      driver = "docker"
      template {
        data        = <<EOT
[[ $config := .csi_openstack_cinder.cloud_conf_file ]][[ fileContents $config ]]
        EOT
        destination = "secrets/cloud.conf"
        change_mode = "restart"
      }
      config {
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:[[ .csi_openstack_cinder.version_tag ]]"
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
          "-v=[[ .csi_openstack_cinder.cinder_log_level ]]",
          "--endpoint=unix:///csi/csi.sock",
          "--cloud-config=/etc/config/cloud.conf",
        ]
      }

      csi_plugin {
        id        = "[[ .csi_openstack_cinder.csi_plugin_id ]]"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}
