job [[ template "job_name" . ]] {
  [[ template "region" . ]]

  datacenters = [[ .csi_openstack_cinder.datacenters | toPrettyJson ]]

  type = system

  group "nodes" {

    restart {
      attempts = [[ .csi_openstack_cinder.job_restart_config.attempts ]]
      delay    = [[ .csi_openstack_cinder.job_restart_config.delay ]]
      mode     = [[ .csi_openstack_cinder.job_restart_config.mode ]]
      interval = [[ .csi_openstack_cinder.job_restart_config.interval ]]
    }
    
    [[ template "constraints" .csi_openstack_cinder.constraints ]]

    [[- template "vault_config" .csi_openstack_cinder -]]

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
        args = [[ .csi_openstack_cinder.cinder_node_args | toPrettyJson ]]
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

        args = [[ .csi_openstack_cinder.cinder_node_args | toPrettyJson ]]

      }

      csi_plugin {
        id        = "[[ .csi_openstack_cinder.csi_plugin_id ]]"
        type      = "controller"
        mount_dir = "/csi"
      }
    }
  }
}