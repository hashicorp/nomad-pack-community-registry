[[- define "location" ]]
  namespace   = "[[ var "namespace" . ]]"
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  node_pool   = [[ var "node_pool" . | quote ]]
[[- end -]]
