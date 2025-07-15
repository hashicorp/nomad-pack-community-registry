[[- define "location" -]]
  namespace   = "[[ var "plugin_namespace" . ]]"
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  node_pool   = [[ var "node_pool" . | quote ]]
[[- end -]]
