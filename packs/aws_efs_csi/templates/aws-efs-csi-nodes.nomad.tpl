job [[ .aws_efs_csi.job_name | quote]] {

  region      = [[ .aws_efs_csi.region | quote]]
  datacenters = [[ .aws_efs_csi.datacenters | toStringList ]]
  node_pool = [[ var "node_pool" . | quote ]]
  type        = "system"
  [[ if .aws_efs_csi.constraints ]][[ range $idx, $constraint := .aws_efs_csi.constraints ]]
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
				image = "[[ .aws_efs_csi.image ]]"
				args = [
					"--endpoint=unix://csi/csi.sock",
					"--logtostderr",
					"--v=2",
				]
				privileged = true
			}
			csi_plugin {
				id        = [[ .aws_efs_csi.csi_id | quote]]
				type      = "monolith"
				mount_dir = "/csi"
			}
      resources {
        cpu    = [[ .aws_efs_csi.resources.cpu ]]
        memory = [[ .aws_efs_csi.resources.memory ]]
      }
    }
  }
}
