Congrats! You deployed the [[ meta "pack.name" . ]] pack on Nomad.

There are [[ var "count" . ]] instances of your job now running.

The service is using the image: [[ var "image" . | quote]]

[[ if var "register_consul_service" . ]]
You registered an associated Consul service named [[ var "consul_service_name" . ]].

[[ if var "has_health_check" . ]]
This service has a health check at the path : [[ var "health_check.path" . | quote ]]
[[ end ]]
[[ end ]]

