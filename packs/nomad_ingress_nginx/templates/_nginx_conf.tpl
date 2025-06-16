[[- define "ingress_conf" -]]
{{- range services -}}
{{- with service .Name -}}
{{- with index . 0}}
  {{- $enabled := false -}}
  {{- $hostname := "" -}}
  {{- $path := "/" -}}
  {{- $port := [[var "http_port" .]] -}}
  {{- $allow := "" -}}
  {{- $deny := "" -}}
  {{- if (index .ServiceMeta "nomad_ingress_enabled") -}}
    {{$enabled = true}}
    {{- if (index .ServiceMeta "nomad_ingress_hostname") -}}
      {{- $hostname = (index .ServiceMeta "nomad_ingress_hostname") -}}
    {{- end -}}
    {{- if (index .ServiceMeta "nomad_ingress_path") -}}
      {{- $path = (index .ServiceMeta "nomad_ingress_path") -}}
    {{- end -}}
    {{- if (index .ServiceMeta "nomad_ingress_port") -}}
      {{- $port = (index .ServiceMeta "nomad_ingress_port") -}}
    {{- end -}}
    {{- if (index .ServiceMeta "nomad_ingress_allow") -}}
      {{- $allow = (index .ServiceMeta "nomad_ingress_allow") -}}
    {{- end -}}
    {{- if (index .ServiceMeta "nomad_ingress_deny") -}}
      {{- $deny = (index .ServiceMeta "nomad_ingress_deny") -}}
    {{- end -}}
  {{- else if .Tags | contains "nomad_ingress_enabled=true" -}}
    {{$enabled = true}}
    {{- range .Tags -}}
      {{- $kv := (. | split "=") -}}
      {{- if eq (index $kv 0) "nomad_ingress_hostname" -}}
        {{- $hostname = (index $kv  1) -}}
      {{- end -}}
      {{- if eq (index $kv 0) "nomad_ingress_path" -}}
        {{- $path = (index $kv  1) -}}
      {{- end -}}
      {{- if eq (index $kv 0) "nomad_ingress_port" -}}
        {{- $port = (index $kv  1) -}}
      {{- end -}}
      {{- if eq (index $kv 0) "nomad_ingress_allow" -}}
        {{- $allow = (index $kv  1) -}}
      {{- end -}}
      {{- if eq (index $kv 0) "nomad_ingress_deny" -}}
        {{- $ = (index $kv  1) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $enabled -}}
  {{- $upstream := .Name | toLower -}}
# Configuration for service {{.Name}}.
upstream {{$upstream}} {
  {{- range service .Name}}
  server {{.Address}}:{{.Port}};
  {{- end}}
}

server {
  listen {{$port}};
  {{- if $hostname}}
  server_name {{$hostname}};
  {{- end}}

  {{- range ($allow | split ",")}}
  allow {{.}};
  {{- end}}
  {{- if ne $allow ""}}
  deny all;
  {{- end}}

  {{- range ($deny | split ",")}}
  deny {{.}};
  {{- end}}
  {{- if ne $deny ""}}
  allow all;
  {{- end}}

  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Port $server_port;

  location {{$path}} {
     proxy_pass http://{{$upstream}};
  }
}
  {{- else}}
# Service {{.Name}} not enabled for ingress.
  {{end}}
{{end}}
{{- end -}}
{{end}}
[[- end -]]
