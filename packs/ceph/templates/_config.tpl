[[- define "config_file" -]]
[[- if var "ceph_config_file" . -]]
[[ var "ceph_config_file" . ]]
[[ else ]][global]
fsid = [[ if var "ceph_cluster_id" . ]][[ var "ceph_cluster_id" . ]][[ else ]][[ uuidv4 ]][[ end ]]
mon initial members = {{ env "attr.unique.hostname" }}
mon host = v2:{{ sockaddr "with $ifAddrs := GetDefaultInterfaces | include \"type\" \"IPv4\" | limit 1 -}}{{- range $ifAddrs -}}{{ attr \"address\" . }}{{ end }}{{ end " }}:[[ var "ceph_monitor_port" . ]]/0

osd crush chooseleaf type = 0
osd journal size = 100
public network = 0.0.0.0/0
cluster network = 0.0.0.0/0
osd pool default size = 1
mon warn on pool no redundancy = false
osd_memory_target =  939524096
osd_memory_base = 251947008
osd_memory_cache_min = 351706112
osd objectstore = bluestore

[osd.0]
osd data = /var/lib/ceph/osd/ceph-0

[client.rgw.linux]
rgw dns name = {{ env "attr.unique.hostname" }}
rgw enable usage log = true
rgw usage log tick interval = 1
rgw usage log flush threshold = 1
rgw usage max shards = 32
rgw usage max user shards = 1
log file = /var/log/ceph/client.rgw.linux.log
rgw frontends = beast  endpoint=0.0.0.0:8080
[[ end ]]
[[ end ]]
