OpenStudio Server pack has been deployed successfully to Nomad !

Consul Service URLs :
-Db Service : http :    //localhost:8500/ui/[[ index (var "datacenters" .) 0 ]]/services/openstudio-db
-Redis Service : http : //localhost:8500/ui/[[ index (var "datacenters" .) 0 ]]/services/openstudio-redis

Traefik Router URL :
-Web UI : http[[ if var "ingress_tls_enabled" . ]]s[[ end ]] : //[[ var "ingress_domain" . ]]

Batch Verification :
-Enable job : nomad-pack run - var "enable_batch_verification=true".
-Metrics lines : batch_verification_result / batch_verification_summary
