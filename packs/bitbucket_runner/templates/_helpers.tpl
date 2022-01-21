// ----------------------------------------------
// allow nomad-pack to set the job name
// ----------------------------------------------

[[- define "job_name" -]]
[[- if eq .bitbucket_runner.job_name "" -]]
[[- .nomad_pack.pack.name -]]
[[- else -]]
[[- .bitbucket_runner.job_name -]]
[[- end -]]
[[- end -]]
