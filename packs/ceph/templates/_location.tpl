[[- define "location" ]]
  namespace   = "[[ var "namespace" . ]]"
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
[[- end -]]
