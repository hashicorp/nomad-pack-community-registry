type         = "csi"
id           = "[[ var "volume_id" . ]]"
namespace    = "[[ var "volume_namespace" . ]]"
plugin_id    = "[[ var "plugin_id" . ]]"

# this is used as the AWS EBS volume's CSIVolumeName tag, and
# must be unique per region
name         = "[[ uuidv4 ]]"

capacity_min = "[[ var "volume_min_capacity" . ]]"
capacity_max = "[[ var "volume_max_capacity" . ]]"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "block-device"
}

parameters {
  type = "[[ var "volume_type" . ]]"
}

topology_request {
  required {
    topology {
      segments {
[[ if var "availability_zones" . -]][[ range $idx, $az := var "availability_zones" . ]]
        "topology.ebs.csi.aws.com/zone" = "[[ $az ]]"
[[- end -]]
[[- end ]]
      }
    }
  }
}
