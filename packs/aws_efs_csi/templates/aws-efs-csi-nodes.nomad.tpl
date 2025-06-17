job [[ var "job_name" . | quote]] {

  region      = [[ var "region" . | quote]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type        = "system"
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[- if $constraint.value ]]
    value     = [[ $constraint.value | quote ]]
    [[- end ]]
    [[- if $constraint.operator  ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "nodes" {
    task "plugin" {
			driver = "docker"
			config {
				image = "[[ var "image" . ]]"
				args = [
					"--endpoint=unix://csi/csi.sock",
					"--logtostderr",
					"--v=2",
				]
				privileged = true
			}
			csi_plugin {
				id        = [[ var "csi_id" . | quote]]
				type      = "monolith"
				mount_dir = "/csi"
			}
      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}
