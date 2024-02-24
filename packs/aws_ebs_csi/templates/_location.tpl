[[- define "location" ]]
  namespace   = "[[ .my.plugin_namespace ]]"
  region      = "[[ .my.region ]]"
  datacenters = [[ .my.datacenters | toJson ]]
  node_pool = [[ .my.node_pool | quote ]]
[[- end -]]
