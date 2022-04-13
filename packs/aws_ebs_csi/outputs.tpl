type         = "csi"
id           = "[[ .my.volume_id ]]"
namespace    = "[[ .my.volume_namespace ]]"
plugin_id    = "[[ .my.plugin_id ]]"

# this is used as the AWS EBS volume's CSIVolumeName tag, and
# must be unique per region
name         = "[[ uuidv4 ]]"

capacity_min = "[[ .my.volume_min_capacity ]]"
capacity_max = "[[ .my.volume_max_capacity ]]"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "block-device"
}

parameters {
  type = "[[ .my.volume_type ]]"
}

topology_request {
  required {
    topology {
      segments {
[[ if .my.availability_zones -]][[ range $idx, $az := .my.availability_zones ]]
        "topology.ebs.csi.aws.com/zone" = "[[ $az ]]"
[[- end -]]
[[- end ]]
      }
    }
  }
}
