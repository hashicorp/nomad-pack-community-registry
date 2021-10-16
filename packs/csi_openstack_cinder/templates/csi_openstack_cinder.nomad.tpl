job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .csi_openstack_cinder.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = system
  group "nodes" {
    restart {
      attempts = 5
      delay    = "15s"
      mode     = "delay"
      interval = "5m"
    }
    constraint {    
        attribute = "${attr.platform.aws.placement.availability-zone}"
        value     = "nova"  
    }
    [[ template "vault_config" . ]]
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
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:latest"
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
          "-v=[[ .csi_openstack_cinder.csi_driver_log_level ]]",
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
        image = "docker.io/k8scloudprovider/cinder-csi-plugin:latest"
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
          "-v=[[ .csi_openstack_cinder.csi_driver_log_level ]]",
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