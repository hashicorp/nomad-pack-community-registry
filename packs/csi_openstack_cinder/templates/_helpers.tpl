// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .csi_openstack_cinder.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .csi_openstack_cinder.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .csi_openstack_cinder.region "") -]]
region = [[ .csi_openstack_cinder.region | quote]]
[[- end -]]
[[- end -]]

[[- define "vault_config" -]]
    [[ if .csi_openstack_cinder.vault_config.enabled ]]
    vault {
      [[- if .csi_openstack_cinder.vault_config.enabled ]]
      policies      = [ [[- range $idx, $pol := .csi_openstack_cinder.vault_config.policies -]][[if $idx]], [[end]][[ $pol | quote ]][[- end -]] ]
      [[- end ]]
      [[- if .csi_openstack_cinder.vault_config.change_mode ]]
      change_mode   = [[ .csi_openstack_cinder.vault_config.change_mode ]]
      [[- end ]]
      [[- if .csi_openstack_cinder.vault_config.change_signal ]]
      change_signal = [[ .csi_openstack_cinder.vault_config.change_signal ]]
      [[- end ]]
      [[- if not ( eq .csi_openstack_cinder.vault_config.env nil ) ]]
      env           = [[ .csi_openstack_cinder.vault_config.env ]]
      [[- end ]]
      [[- if .csi_openstack_cinder.vault_config.namespace ]]
      namespace     = [[ .csi_openstack_cinder.vault_config.namespace ]]
      [[- end ]]
    }
    [[ end ]]
[[- end -]]
