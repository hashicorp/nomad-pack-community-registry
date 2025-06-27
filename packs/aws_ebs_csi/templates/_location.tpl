[[- define "location" ]]
  namespace   = "[[ var "plugin_namespace" . ]]"
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
[[- end -]]
