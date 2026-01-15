[[ define "location" ]]
  namespace   = "[[ .my.namespace ]]"
  region      = "[[ .my.region ]]"
  datacenters = [[ .my.datacenters | toJson ]]
[[- end -]]
