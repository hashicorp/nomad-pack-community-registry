[[ define "location" ]]
  namespace   = "[[ .my.plugin_namespace ]]"
  region      = "[[ .my.region ]]"
  datacenters = [[ .my.datacenters | toJson ]]
[[- end -]]
